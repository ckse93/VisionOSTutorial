//
//  GeometryHelpers.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/14/24.
//

import Foundation
import RealityKit
import UIKit
import ARKit

extension simd_float4x4 {
    var xAxis: SIMD3<Float> { columns.0.xyz }
    var yAxis: SIMD3<Float> { columns.1.xyz }
    var zAxis: SIMD3<Float> { columns.2.xyz }
    
    var translation: SIMD3<Float> {
        get {
            columns.3.xyz
        } set {
            self.columns.3 = [newValue.x, newValue.y, newValue.z]
        }
    }
    
    var rotation: simd_quatf {
        simd_quatf(rotationMatrix)
    }
    
    var rotationMatrix: simd_float3x3 {
        matrix_float3x3(xAxis, yAxis, zAxis)
    }
}

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0,1,2)]
    }
}
