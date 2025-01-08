#!/usr/bin/env python3

'''
Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc. ("Apple") in consideration of your
agreement to the following terms, and your use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject to these terms, Apple grants you a
personal, non-exclusive license, under Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without modifications, in source and/or binary
forms; provided that if you redistribute the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions of the Apple Software. Neither the name,
trademarks, service marks or logos of Apple Inc. may be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple. Except as expressly stated in this notice, no other rights or licenses,
express or implied, are granted by Apple herein, including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT
LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE
SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY
OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.

Copyright (C) 2024 Apple Inc. All Rights Reserved.
'''

import os, sys, json
import array
from math import sqrt, asin
import math
try:
    from pxr import Usd, Sdf, UsdGeom, Gf
except:
    print("Unable to import USD libraries")

import random

# Generates 5000 randomly scattered points along the given XY plane
def computeDockingRegionPoints(width, height, center, count):
    halfWidth = width/2.0
    halfHeight = height/2.0

    points = []

    for i in range(count):
        # random u and v coordinates in the 0...1 range
        u = random.random()
        v = random.random()

        # distribute u and v along plane
        x = -halfWidth + width*u
        y = -halfHeight + height*v

        # compute point attributes
        position = center + Gf.Vec3f(x, y, 0.0)
        normal = Gf.Vec3f(0,0,-1)
        uv = Gf.Vec2f(u,v)

        # append point to list
        point = (position, normal, uv)
        points.append(point)

    return points

# compute Emitter UVs
def computeEmitterUVs(prim, terrainPositions, screenPoints, exponent, verbose):
    # split out screen point data into position, normal, uv arrays
    screenPositions = []
    screenNormals = []
    screenUVs = []
    for screenPoint in screenPoints:
        screenPositions.append(screenPoint[0])
        screenNormals.append(screenPoint[1])
        screenUVs.append(screenPoint[2])

    emitterUVs = []

    localPercentage = 0
    localCurrentPoint = 0
    localTotalPoints = len(terrainPositions) * len(screenPoints)

    # loop over terrain vertices
    for terrainPosition in terrainPositions:
        # accumulators
        u = 0.0
        v = 0.0
        weight = 0.0

        global GLOBAL_CURRENT_PERCENTAGE
        global GLOBAL_CURRENT_POINT
        global GLOBAL_TOTAL_POINTS
        
        # loop over screen vertices
        for i in range(len(screenPoints)):
            # log completion percentage
            newLocalPercentage = int(float(localCurrentPoint)/float(localTotalPoints)*100)
            if newLocalPercentage is not localPercentage:
                globalPercentage = int(float(GLOBAL_CURRENT_POINT)/float(GLOBAL_TOTAL_POINTS)*100)
                localPercentage = newLocalPercentage
                if verbose:
                    print("INFO: {}% complete (\"{}\" is {}% complete)".format(globalPercentage, prim.GetName(), newLocalPercentage))
            localCurrentPoint += 1
            GLOBAL_CURRENT_POINT += 1

            screenPosition = screenPositions[i]
            screenNormal = screenNormals[i]
            screenU = screenUVs[i][0]
            screenV = screenUVs[i][1]
        
            # compute screen point to geometry point info
            screenPositionToTerrainPosition = (terrainPosition - screenPosition)
            screenDistance = Gf.GetLength(screenPositionToTerrainPosition)
        
            # compute the falloff factors
            distanceFactor = 1.0 / pow(screenDistance, exponent)
            angleFactor = abs(Gf.Dot(screenNormal, screenPositionToTerrainPosition))
            factor = distanceFactor * angleFactor
        
            # update accumulators
            u += factor * screenU
            v += factor * screenV
            weight += factor

        # normalize u and v by weight
        if weight > 0.0:
            u /= weight
            v /= weight

        # set the computed emitter UV back on the terrain vertex
        emitterUVs.append(Gf.Vec2f(u,v))

    return emitterUVs

# compute Attenuation UVs
def computeAttenuationUVs(terrainPositions, dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, attenuationUStart, attenuationUEnd, attenuationVStart, attenuationVEnd):
    attenuationUVs = []
    # loop over terrain vertices
    for terrainPosition in terrainPositions:
        def remap(v, fromMin, fromMax, toMin, toMax):
            return (v - fromMin)/(fromMax - fromMin)*(toMax - toMin) + toMin
        
        # map vertex x from (-dockingRegionHalfWidth, dockingRegionHalfWidth) in world space to (uStart, uEnd) in uv space
        u = remap(terrainPosition[0], dockingRegionPosition[0] - dockingRegionWidth*0.5, dockingRegionPosition[0] + dockingRegionWidth*0.5, attenuationUStart, attenuationUEnd)

        # map vertex z from (dockingRegionPosition, dockingRegionPosition+dockingRegionWidth) in world space to (vStart, vEnd) in uv space
        v = 1.0 - remap(terrainPosition[2], dockingRegionPosition[2], dockingRegionPosition[2] + dockingRegionWidth, attenuationVStart, attenuationVEnd)
        
        attenuationUVs.append(Gf.Vec2f(u,v))
    
    return attenuationUVs

# Whether or not we want to use this prim, with the given options.
def usePrim(prim, options):
    # ignore non-mesh prims
    if not prim.IsA(UsdGeom.Mesh):
        return False
    
    # if enabled, ignore prims without the specified substring
    if options.onlyWithSubstring:
        if not options.onlyWithSubstring in prim.GetName():
            return False

    return True

# Whether or not the given string value is "true".
def stringToBool(val):
    if val.lower() in ['y', 'yes', 't', 'true', 'on', '1']:
        return True
    else:
        return False

# computes diffuse reflection (emitter and attenuation) UVs for the given prim.
def computeDiffuseReflectionUVs(prim, options, dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, screenPoints):    
    if usePrim(prim, options):
        # get mesh from prim
        mesh = UsdGeom.Mesh(prim)
        positionsAttribute = mesh.GetPointsAttr()

        # get positions from mesh
        positions = positionsAttribute.Get()
        if positionsAttribute.GetNumTimeSamples() > 0:
            warning = "WARNING: \"{}\" has multiple point time-samples. Only the first time-sampled points will be used for diffuse reflection UV computation.".format(prim.GetName())
            print(warning)
            GLOBAL_WARNINGS.append(warning)
            positions = positionsAttribute.Get(positionsAttribute.GetTimeSamples()[0])

        # transform from local to world
        xform = UsdGeom.Xformable(prim)
        localToWorld = xform.ComputeLocalToWorldTransform(Usd.TimeCode.Default())
        print('lalalalala')
        print(localToWorld)
        for i in range(len(positions)):
            gfvec3f = Gf.Vec3f(positions[i])
            print(f"gfvec3f is = {gfvec3f}")
            # zack: ugh I need to force cast this?
            positions[i] = Gf.Vec3f(localToWorld.Transform(gfvec3f))

        # compute emitter UVs
        emitterUVs = computeEmitterUVs(prim, positions, screenPoints, options.emitterUVExponent, stringToBool(options.verbose))
        emitterPrimvars = UsdGeom.PrimvarsAPI(prim).CreatePrimvar(options.emitterUVName, Sdf.ValueTypeNames.TexCoord2fArray, UsdGeom.Tokens.varying)
        emitterPrimvars.Set(emitterUVs)

        # compute attenuation UVs
        attenuationUVs = computeAttenuationUVs(positions, dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, options.attenuationUStart, options.attenuationUEnd, options.attenuationVStart, options.attenuationVEnd)
        attenuationPrimvars = UsdGeom.PrimvarsAPI(prim).CreatePrimvar(options.attenuationUVName, Sdf.ValueTypeNames.TexCoord2fArray, UsdGeom.Tokens.varying)
        attenuationPrimvars.Set(attenuationUVs)

    # recurse
    if stringToBool(options.recursive):
        for childPrim in prim.GetChildren():
            computeDiffuseReflectionUVs(childPrim, options, dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, screenPoints)

# Counts the number of points in the given prim.
def computePointCount(prim, options):
    pointCount = 0

    if usePrim(prim, options):
        mesh = UsdGeom.Mesh(prim)
        positionsAttribute = mesh.GetPointsAttr()
        if positionsAttribute.GetNumTimeSamples() > 0:
            pointCount += len(positionsAttribute.Get(positionsAttribute.GetTimeSamples()[0]))
        else:
            pointCount += len(positionsAttribute.Get())
 
    if stringToBool(options.recursive):
        for childPrim in prim.GetChildren():
            pointCount += computePointCount(childPrim, options)
    
    return pointCount

if __name__ == "__main__":
    # seed the random number generaotr
    random.seed(102496)

    # setup arg parser
    from optparse import OptionParser
    import sys
    parser = OptionParser("computeDiffuseReflectionUVs <input.usd> ")

    parser.add_option("-p", "--prim",
                    dest="prim", default=None, type=str,
                    help="prim path to the submesh you want to add diffuse reflection UVs to")
    
    parser.add_option("-r", "--recursive",
                    dest="recursive", default='false', type=str,
                    help="Whether or not to recursively compute diffuse reflection UVs for all prims under the specified prim")

    parser.add_option("", "--onlyWithSubstring",
                    dest="onlyWithSubstring", default=None, type=str,
                    help="Limit computation to only the prims those whose name contains the specified substring")

    parser.add_option("-x", "--dockingRegionCenterX",
                    dest="dockingRegionCenterX", default=0, type=float,
                    help="the x-coordinate of the center of the docking region, in world space")
    
    parser.add_option("-y", "--dockingRegionCenterY",
                    dest="dockingRegionCenterY", default=0.5, type=float,
                    help="the y-coordinate of the center of the docking region, in world space")
    
    parser.add_option("-z", "--dockingRegionCenterZ",
                    dest="dockingRegionCenterZ", default=0, type=float,
                    help="the z-coordinate of the center of the docking region, in world space")

    parser.add_option("-w", "--dockingRegionWidth",
                    dest="dockingRegionWidth", default=2.4, type=float,
                    help="the width of the docking region")

    parser.add_option("-e", "--emitterUVName",
                    dest="emitterUVName", default="primvar:emissionUV", type=str,
                    help="name of the computed emitter UVs")

    parser.add_option("", "--emitterUVExponent",
                    dest="emitterUVExponent", default=6.0, type=float,
                    help="the exponent used to control the fan-out of the emitter UVs")

    parser.add_option("-a", "--attenuationUVName",
                    dest="attenuationUVName", default="primvar:attenuationUV", type=str,
                    help="name of the computed attenuation UVs")
   
    parser.add_option("", "--attenuationUStart",
                    dest="attenuationUStart", default=0.396, type=float,
                    help="the horizontal start of the sharp line, in uv space")
    
    parser.add_option("", "--attenuationUEnd",
                    dest="attenuationUEnd", default=0.604, type=float,
                    help="the horizontal end of the sharp line, in uv space")

    parser.add_option("", "--attenuationVStart",
                    dest="attenuationVStart", default=0.097, type=float,
                    help="the vertical start of the sharp line, in uv space")
    
    parser.add_option("", "--attenuationVEnd",
                    dest="attenuationVEnd", default=0.5, type=float,
                    help="the vertical end of the sharp line, in uv space")
    
    parser.add_option("-s", "--sampleCount",
                    dest="sampleCount", default=5000, type=int,
                    help="the number of random samples used for emitter UV calculation. reducing this number can speed up computation, at the cost of potential artifacts")
    
    parser.add_option("-o", "--out",
                    dest="out", default=None, type=str,
                    help="output file name")
    
    parser.add_option("-v", "--verbose",
                    dest="verbose", default='true', type=str,
                    help="print detailed information about the computation")

    # parse args
    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(2)

    try:
        stage = Usd.Stage.Open(args[0])
    except:
        print("ERROR: unable to open \"%s\" as a USD file" % args[0])
        sys.exit(2)

    # get main prim to compute UVs for
    prim = stage.GetPrimAtPath(options.prim)
    if not prim:
        print("ERROR: unable to get specified prim \"%s\" " % options.prim)
        sys.exit(2)

    if not options.out:
        print("ERROR: no output file specified")
        sys.exit(2)

    if options.out == args[0]:
        print("ERROR: output file should not be the same as input file")
        sys.exit(2)

    # setup global percentage variables
    global GLOBAL_TOTAL_POINTS
    global GLOBAL_CURRENT_POINT
    global GLOBAL_CURRENT_PERCENTAGE
    global GLOBAL_WARNINGS

    GLOBAL_TOTAL_POINTS = computePointCount(prim, options) * options.sampleCount
    GLOBAL_CURRENT_POINT = 0
    GLOBAL_CURRENT_PERCENTAGE = 0
    GLOBAL_WARNINGS = []

    # compute docking region info
    dockingRegionWidth = float(options.dockingRegionWidth)
    dockingRegionHeight = dockingRegionWidth/2.4  # docking region is always 2.4x1 aspect ratio
    dockingRegionPosition = Gf.Vec3f(float(options.dockingRegionCenterX), float(options.dockingRegionCenterY), float(options.dockingRegionCenterZ))

    # compute screen points
    screenPoints = computeDockingRegionPoints(dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, options.sampleCount)

    # compute diffuse reflection UVs
    print(f"prim = {prim}, options = {options}, dockingRegionWidth = {dockingRegionWidth}")
        #print(f"dockingRegionWidth = {dockingRegionWidth}, dockingRegionPosition = {dockingRegionPosition}, screenPoints = {screenPoints}")
    computeDiffuseReflectionUVs(prim, options, dockingRegionWidth, dockingRegionHeight, dockingRegionPosition, screenPoints)

    # export
    if options.out:
        stage.GetRootLayer().Export(options.out)

    # print derived params
    if options.verbose:
        print("")
        print("Finished computing diffuse reflection UVs. Please use the following options in Reality Composer Pro:")
        print("- emitter UV name = \"{}\"".format(options.emitterUVName))
        print("- attenuation UV name = \"{}\"".format(options.attenuationUVName))
        print("- docking region X = {} m".format(options.dockingRegionCenterX))
        print("- docking region Y = {} m".format(options.dockingRegionCenterY))
        print("- docking region Z = {} m".format(options.dockingRegionCenterZ))
        print("- docking region width = {} m".format(options.dockingRegionWidth))

        if options.attenuationUStart is 0.396 and options.attenuationUEnd is 0.604 and options.attenuationVStart is 0.097 and options.attenuationVEnd is 0.5:
            print("- no custom attenuation UV measurements provided, therefore please ensure you use the default attenuation texture provided by Reality Composer Pro")
        else:
            print("- custom attenuation UV measurements provided, therefore please ensure you use your custom attenuation texture within Reality Composer Pro")

    if len(GLOBAL_WARNINGS) > 0:
        print("")
        print("Finished with the following warnings:")    
        for warning in GLOBAL_WARNINGS:
            print("- " + warning)
