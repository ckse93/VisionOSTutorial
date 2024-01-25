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
        self.components.set(PhysicsBodyComponent(mode: .kinematic))
        self.collision = CollisionComponent(shapes: [.generateBox(size: .random(in: (30...32)))], isStatic: true)
        self.physicsBody = PhysicsBodyComponent()
    }
}
