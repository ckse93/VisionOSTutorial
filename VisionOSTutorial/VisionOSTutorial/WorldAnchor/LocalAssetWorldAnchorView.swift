//
//  LocalAssetRealityView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/12/23.
//

import ARKit
import SwiftUI
import RealityKit

let objectDatabaseFileName = "worldAnchoredObjects.json"

@MainActor // cuz PlacementManager.init is @MainActor
struct LocalAssetWorldAnchorView: View {
    var appState: AppState
    @State var placementManager = PlacementManager()
    let assetName: AssetName
    
    var body: some View {
        RealityView { content in
            placementManager.appState = self.appState
            content.add(placementManager.rootEntity)
            
            Task {
                await placementManager.runARSession()
            }
            
            if let asset = try? await ModelEntity(named: assetName.rawValue) {
                await placementManager.placeFetchedObjectLALALA(asset)
            }
        }
        .task {
            // Monitor ARKit anchor updates once the user opens the immersive space.
            //
            // Tasks attached to a view automatically receive a cancellation
            // signal when the user dismisses the view. This ensures that
            // loops that await anchor updates from the ARKit data providers
            // immediately end.
            await placementManager.processWorldAnchorUpdates()
        }
    }
}
