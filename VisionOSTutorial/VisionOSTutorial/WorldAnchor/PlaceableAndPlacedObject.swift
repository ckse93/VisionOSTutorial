//
//  PlaceableAndPlacedObject.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import Foundation
import RealityKit

struct ModelDescriptor: Identifiable, Hashable {
    let fileName: String
    let displayName: String
    var id: String { self.fileName }
    
    init(fileName: String, displayName: String? = nil) {
        self.fileName = fileName
        self.displayName = displayName ?? fileName
    }
}

final class PlacedObject: Entity {
    let descriptor: ModelDescriptor
    let fileName: String
    
    let modelEntity: ModelEntity
    init(descriptor: ModelDescriptor,
         modelEntity: ModelEntity
    ) {
        self.descriptor = descriptor
        self.fileName = descriptor.fileName
        self.modelEntity = modelEntity.clone(recursive: true)
        
        super.init()
        name = modelEntity.name
        
        addChild(modelEntity)
        
        // making it touchable
        components.set(InputTargetComponent(allowedInputTypes: [.direct, .indirect]))
        generateCollisionShapes(recursive: true)
    }
    
    @MainActor required init() {
        fatalError("init() has not been implemented")
    }
}

@MainActor
final class PlaceableObject {
    let descriptor: ModelDescriptor
    var modelEntity: ModelEntity
    
    init(descriptor: ModelDescriptor,
         modelEntity: ModelEntity
    ) {
        self.descriptor = descriptor
        self.modelEntity = modelEntity
    }
}
