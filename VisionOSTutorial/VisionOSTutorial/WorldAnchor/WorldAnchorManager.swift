//
//  WorldAnchorManager.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import Foundation
import ARKit
import RealityKit

final class WorldAnchorManager {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    /// same as PlacementManager's rootEntity
    private var rootEntity: Entity
    
    private var worldTracking: WorldTrackingProvider
    
    /// a map of WorldAnchor's UUIDs to PlacedObjects.
    private var anchoredObjects: [UUID: PlacedObject] = [:]
    
    /// a map of WorldAnchor UUIDs to the objects that are about to be attached to them
    private var objectsBeingAnchored: [UUID: PlacedObject] = [:]
    
    /// a dictonary of all current WorldAnchors based on the anchor updates from ARKit.
    private var worldAnchors: [UUID: WorldAnchor] = [:]
    
    /// a dictionary of 3D model files to be loaded for a givent persistent world anchor uuid
    private var persistedObjectFileNamePerWorldAnchorUUID: [UUID: String] = [:]
    
    var placeableObjectsByFileName: [String: PlaceableObject] = [:]
    
    init(rootEntity: Entity,
         worldTracking: WorldTrackingProvider
    ) {
        self.rootEntity = rootEntity
        self.worldTracking = worldTracking
    }
    
    // MARK: saving to / restoring from file
    
    /// populate persistedObjectFileNamePerWorldAnchorUUID from documents directory
    /// does not actually place object
    func loadPersistedObjects() {
        let docDirectory = FileManager.documentDirectory
        let filePath = docDirectory.first?.appendingPathComponent(objectDatabaseFileName)
        
        guard let filePath, FileManager.default.fileExists(atPath: filePath.path(percentEncoded: true)) else {
            print("🍏❌ Could not find file: \(objectDatabaseFileName), skipping loadPersistedObjects operation")
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            persistedObjectFileNamePerWorldAnchorUUID = try decoder.decode([UUID:String].self, from: data)
            print("🍏 successfully decoded json: \(String(decoding: data, as: UTF8.self))")
        } catch {
            print("❌failed to restore world anchors to persisted objects")
        }
    }
    
    func saveWorldAnchorsObjectsMapToDisk() {
        var worldAnchorsToFileNameMap: [UUID: String] = [:]
        
        // iterate thru already anchored objects, extract relavent info
        for (worldAnchorId, object) in anchoredObjects {
            worldAnchorsToFileNameMap[worldAnchorId] = object.fileName
        }
        
        do {
            let jsonString = try encoder.encode(worldAnchorsToFileNameMap)
            let docDirectory = FileManager.documentDirectory[0]
            let filePath = docDirectory.appendingPathComponent(objectDatabaseFileName)
            
            do {
                try jsonString.write(to: filePath)
                print("🍏 successfully wrote to filePath: \(filePath)")
            } catch {
                print("❌ made json, but failed to write to file, Error: \(error.localizedDescription)")
            }
            
        } catch {
            print("❌ failed to encode to json, Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: WorldAnchor operations
    
    @MainActor
    func processWorldAnchorUpdate(_ worldAnchorUpdate: AnchorUpdate<WorldAnchor>) {
        let worldAnchor = worldAnchorUpdate.anchor
        
        // first, see if we need to remove existing anchor or update/add our worldAnchors
        switch worldAnchorUpdate.event {
        case .added, .updated:
            worldAnchors[worldAnchor.id] = worldAnchor
        case .removed:
            worldAnchors.removeValue(forKey: worldAnchor.id)
        }
        
        switch worldAnchorUpdate.event {
        case .added:
            // check if there is a persisted object attached to this anchor
            // it could be a world anchor from the previous run of the app
            // ARKit summons all world anchors associated with this app
            // when world tracking provider starts
            if let persistedObjectFileName = persistedObjectFileNamePerWorldAnchorUUID[worldAnchor.id] {
                self.attachPersistedObjectToWorldAnchor(persistedObjectFileName, worldAnchor: worldAnchor)
                print("🍏 persistedObjectFileName for anchorID: \(worldAnchor.id) exists, adding now")
            } else if let objectBeingAnchored = objectsBeingAnchored[worldAnchor.id] {
                objectsBeingAnchored.removeValue(forKey: worldAnchor.id)
                anchoredObjects[worldAnchor.id] = objectBeingAnchored
                
                // now that anchor has been successfully added, display the object
                rootEntity.addChild(objectBeingAnchored)
                print("🍏 objectBeingAnchored anchored to the rootEntity at WorldAnchorManager")
            } else {
                Task {
                    await removeAnchorWithID(worldAnchor.id)
                }
            }
            fallthrough  // if worldAnchor is added, do update block as well.
        case .updated:
            // Keep the position of placed objects in sync with their corresponding
            // world anchor, and hide the object if the anchor isn’t tracked.
            guard let placedObject = anchoredObjects[worldAnchor.id] else {
                print("❌ no placed object to update for id: \(worldAnchor.id)")
                break
            }
            
            placedObject.position = worldAnchor.originFromAnchorTransform.translation
            placedObject.orientation = worldAnchor.originFromAnchorTransform.rotation
            placedObject.isEnabled = worldAnchor.isTracked
        case .removed:
            guard let placedObject = anchoredObjects[worldAnchor.id] else {
                print("❌ no placed object to remove for id: \(worldAnchor.id)")
                break
            }
            placedObject.removeFromParent()
            anchoredObjects.removeValue(forKey: worldAnchor.id)
        }
    }
    
    @MainActor // no main actor in the other proj
    func removeAnchorWithID(_ uuid: UUID) async {
        do {
            try await worldTracking.removeAnchor(forID: uuid)
        } catch {
            print("❌ Failed to delete world anchor \(uuid) with error \(error).")
        }
    }
    
    @MainActor
    func attachPersistedObjectToWorldAnchor(_ fileName: String, worldAnchor: WorldAnchor) {
        guard let placeableObject: PlaceableObject = placeableObjectsByFileName[fileName] else {
            print("❌🍏 no PlaceableObject found for filename: \(fileName)")
            return
        }
        
        let modelEntity = placeableObject.modelEntity
        modelEntity.position = worldAnchor.originFromAnchorTransform.translation
        modelEntity.orientation = worldAnchor.originFromAnchorTransform.rotation
        modelEntity.isEnabled = worldAnchor.isTracked
        rootEntity.addChild(modelEntity)
        print("adding modelEntity from saved file, displayName: \(placeableObject.descriptor.displayName) \nfileName: \(fileName)")
        
        // now that you added that modelEntity to the scene, update anchoredObject
        anchoredObjects[worldAnchor.id] = PlacedObject(descriptor: placeableObject.descriptor,
                                                       modelEntity: placeableObject.modelEntity)
    }
    
    @MainActor
    func attachObjectToWorldAnchor(_ object: PlacedObject) async {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: object.transformMatrix(relativeTo: nil))
        
        objectsBeingAnchored[worldAnchor.id] = object
        do {
            try await worldTracking.addAnchor(worldAnchor)
            print("🍏 worldAnchor added to worldTracking")
        } catch {
            print("❌ Cannot add world anchor to world tracking, error: \(error.localizedDescription)")
            
            // clean up
            objectsBeingAnchored.removeValue(forKey: worldAnchor.id)
            object.removeFromParent()
        }
    }
}
