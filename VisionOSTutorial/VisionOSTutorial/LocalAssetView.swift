//
//  LocalAssetView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import ARKit
import SwiftUI
import RealityKit
@MainActor // cuz PlacementManager.init is @MainActor
struct LocalAssetRealityView: View {
    let assetName: AssetName
    var body: some View {
        RealityView { content in
            if let asset = try? await ModelEntity(named: assetName.rawValue) {
                content.add(asset)
            }
        }
    }
}
