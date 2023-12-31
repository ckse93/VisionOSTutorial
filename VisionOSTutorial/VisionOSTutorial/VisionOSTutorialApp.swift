//
//  VisionOSTutorialApp.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI

@main
struct VisionOSTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        WindowGroup(id: WindowDestination.myModelView1) {
            MyModelView()
        }
        WindowGroup(id: WindowDestination.myModelView2) {
            MyModelView2()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        
        ImmersiveSpace(id: WindowDestination.localAssetReality,
                       for: AssetName.self) { assetName in
            if let assetName = assetName.wrappedValue {
                LocalAssetRealityView(assetName: assetName)
            }
        }
    }
}

enum AssetName: String, Codable, Hashable {
    case chair = "chair_swan"
    case gramophone = "gramophone"
    case wateringcan = "wateringcan"
    case guitar = "gtr"
}

struct WindowDestination {
    static let myModelView1 = "myModelView1"
    static let myModelView2 = "myModelView2"
    static let myModelView3 = "myModelView3"
    static let localAssetReality = "localAssetReality"
}
