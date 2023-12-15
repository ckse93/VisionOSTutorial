//
//  LocalAssetRealityView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/12/23.
//

import SwiftUI
import RealityKit

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
