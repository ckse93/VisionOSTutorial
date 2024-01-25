//
//  ModelEntity + Helper.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/24/24.
//

import Foundation
import RealityKit

extension ModelEntity {
    func makeTappable() {
        self.components.set(InputTargetComponent())
        self.generateCollisionShapes(recursive: true)
    }
}
