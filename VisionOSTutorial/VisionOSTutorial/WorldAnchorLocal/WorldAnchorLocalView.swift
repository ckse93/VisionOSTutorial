//
//  WorldAnchorLocalView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/18/24.
//

import SwiftUI
import RealityKit

struct WorldAnchorLocalView: View {
    let assetName: AssetName
    var body: some View {
        RealityView { content in
            if let asset = try? await ModelEntity(named: assetName.rawValue) {
                content.add(asset)
            }
        }
    }
}
