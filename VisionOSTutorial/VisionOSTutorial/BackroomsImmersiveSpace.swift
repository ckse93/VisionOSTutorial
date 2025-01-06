//
//  BackroomsImmersiveSpace.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/5/25.
//

import SwiftUI
import RealityKit

struct BackroomsImmersiveSpace: View {
    @Environment(ImmersiveEnvManager.self) var immersiveEnvManager
    
    var body: some View {
        RealityView { content in
            if let entity = immersiveEnvManager.backrooms {
                content.add(entity)
            }
        }
    }
}
