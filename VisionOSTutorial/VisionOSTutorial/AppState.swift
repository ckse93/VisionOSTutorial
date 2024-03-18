//
//  AppState.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import Foundation
import ARKit
import RealityKit

@Observable
final class AppState {
    private(set) var placementManager: PlacementManager? = nil
    
    private(set) var placeableObjectsByFileName: [String : PlaceableObject] = [:]
    private(set) var modelDescriptors: [ModelDescriptor] = []
    var selectedFileName: String? = nil
    
    var arSession = ARKitSession()
}
