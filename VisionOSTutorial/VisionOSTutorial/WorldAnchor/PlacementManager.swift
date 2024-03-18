//
//  PlacementManager.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import Foundation
import ARKit
import RealityKit

@Observable
final class PlacementManager {
    var appState: AppState? = nil {
        didSet {
            print("🍏 appstate has been set")
            if let placeable = appState?.placeableObjectsByFileName {
                worldAnchorManger.placeableObjectsByFileName = placeable
                print("🍏 appstate placeableObjectsByFileName")
            } else {
                worldAnchorManger.placeableObjectsByFileName = [:]
                print("🍏❌ appState has no placeableObjectsByFileName")
            }
        }
    }
    
    private let worldTracking = WorldTrackingProvider()
    private let planeDetection = PlaneDetectionProvider()
    
    private var worldAnchorManger: WorldAnchorManager
    
    var rootEntity: Entity
    private var placementLocation: Entity
    
    @MainActor
    init() {
        let root = Entity()
        self.rootEntity = root
        self.placementLocation = Entity()
        
        self.worldAnchorManger = .init(rootEntity: root,
                                       worldTracking: self.worldTracking)
        self.worldAnchorManger.loadPersistedObjects()
        
        rootEntity.addChild(placementLocation)
    }
    
    @MainActor
    func runARSession() async {
        do {
            try await appState!.arSession.run([self.worldTracking, self.planeDetection])
        } catch {
            return
        }
        
        if let fileName = appState?.modelDescriptors.first?.fileName,
           let object = appState?.placeableObjectsByFileName[fileName] {
            print("🍏 there exists \(fileName) , but currently not doing anything, it should 'select(object)' tho")
        }
    }
    
    @MainActor
    func processWorldAnchorUpdates() async {
        for await worldAnchorUpdate in worldTracking.anchorUpdates {
            self.worldAnchorManger.processWorldAnchorUpdate(worldAnchorUpdate)
        }
    }
    
    @MainActor
    func placeFetchedObjectLALALA(_ fetchedModelEntity: ModelEntity) async {
        let placedObject = PlacedObject(descriptor: .init(fileName: "\(fetchedModelEntity.name + UUID.init().uuidString)"),
                                        modelEntity: fetchedModelEntity)
        await worldAnchorManger.attachObjectToWorldAnchor(placedObject)
    }
}
