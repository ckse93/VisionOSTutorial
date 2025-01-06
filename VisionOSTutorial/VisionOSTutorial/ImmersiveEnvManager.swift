//
//  ImmersiveEnvManager.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/5/25.
//

import Foundation
import Backrooms
import SwiftUI
import RealityKit

@MainActor
@Observable
class ImmersiveEnvManager {
    public private(set) var backrooms: Entity?
    
    @MainActor
    public func loadAsset() async {
        do {
            if self.backrooms == nil {
                self.backrooms = try await Entity(named: "BackRoomScene", in: backroomsBundle)
            }
        } catch {
            print("error loading asset: \(error)")
        }
    }
}
