Python Script Usage
----------------------------------------------

We wrote a little python tool which can generate these UVs for you.  It requires a python 3
installation, which access to the USD python library. If you do not have the USD python
library installed, you can install it with 'pip3 install usd-core'.

Usage is as follows:

    python3 computeDiffuseReflectionUVs.py <input.usd> -o <output.usd> -p / -r true

The full arguments list is below:

* -o or --out: the name of the output file. The output file is an exact copy of the input
  file, with the two newly generated diffuse reflection UV primvars added.
    * e.g. -o myNewGeo.usd
    * This argument is required, and ideally should not be the same as the input file.
    * NOTE: the output is essentially a copy of the input USD file, not a reference. If
            you make changes to the input USD file, you will need to re-run the script
            to pick up those changes.

* -p or --prim: the name of the USD prim corresponding to the USD Mesh object(s) you want
  to compute diffuse reflection UVs for.
    * e.g. --prim "/" 
    * This argument is required.
    * NOTE: Diffuse reflection UVs are generated for USD Mesh objects only, so if you are
            using instances in your input file, the generated UVs will not be correct
            since the UVs are computed per-mesh, not per-instance. Any instanced meshes
            for which you want to generate diffuse reflection UVs need to be de-instanced
            into their own unique Mesh objects.
    * NOTE: The algorithm relies on the USD Mesh points. If the points attribute is time-
            sampled, it will only use the first time-sample. (Time-sampled lightspill UVs
            are not supported).

* -r or --recursive: if present, computes diffuse reflection UVs for the USD prim speci-
  fied by -p, and all of its descendants.
    * e.g. -r true
    * This argument is optional, the default is “false”.

* --onlyWithSubstring: if present (and if -r is present), ignores USD prims whose name
  does not contain the specified substring.
    * e.g. --onlyWithSubtring "lightspill"
    * This argument is optional, the default is off.

* -x or --dockingRegionCenterX: the world-space X component of the center of the docking
  region.
    * e.g. -x 0 
    * This argument is optional. The default is 0, and the expected value is 0. 

* -y or --dockingRegionCenterY: the world-space Y component of the center of the docking
  region.
    * e.g. -y 4.6
    * This argument is optional. The default is 0.5, and the expected range of values is
      -infinity to +infinity.

* -z or --dockingRegionCenterZ: the world-space Z component of the center of the docking
  region.
    * e.g. -z -36
    * This argument is optional. The default is 0, and the expected range of values is
      -infinity to +infinity.
* -w or --dockingRegionWidth: the world-space width of the docking region.
    * e.g. -w 41.25 
    * This argument is optional. The default is 2.4, and the expected range of values
      is > 0.

* -e or --emitterUVName: the name of the UV data channel (known as a primvar  in USD)
  where the computed emitter UVs will be stored.
    * e.g. -e primvars:emissionUV 
    * This argument is optional, the default is primvars:emissionUV

* --emitterUVExponent: the exponent used for the emitter UV falloff. Can be used to arti-
  stically control how far out the diffuse reflection colors appear.
    * e.g. --emitterUVExponent 6.0
    * This argument is optional. The default is 6.0, and the expected range of values
      is >= 2.0

* -s or --sampleCount: the number of random samples used during emitter UV calculation.
  Decreasing this number can speed up computation time, at the cost of potential artifacts.
    * e.g. -s 5000
    * This argument is optional. The default value is 5000 and the expected range of values
      is > 0
* -a or --attenuationUVName: the name of the UV data channel (known as a primvar in USD)
  where the computed attenuation UVs will be stored.
    * e.g. -a primvars:attenuationUV 
    * This argument is optional, the default is primvars:attenuationUV

* --attenuationUStart, --attenuationUEnd, --attenuationVStart, --attenuationVEnd: the
  attenuation texture measurements which control how the attenuation texture is top-down
  projected onto the geometry. Please see the “Measuring Attenuation Textures” section above.
    * e.g. --attenuationUStart 0.25 --attenuationUEnd 0.75 --attenuationVStart 0
      -- attenuationVEnd 1.0 
    * These arguments are optional. If they are not provided, values corresponding to
      Reality Composer Pro’s default provided attenuation texture will be used. The expec-
      ted range of these values are 0 to 1.

* -v or --verbose: prints out script completion percentage, and helpful information for
  setting up the resulting USD file in Reality Composer Pro.
    * e.g. -v true
    * This argument is optional. The default is true.
