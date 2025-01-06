//
//  VisionOSTutorialApp.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI

@main
struct VisionOSTutorialApp: App {
    @State var immersiveEnvManager = ImmersiveEnvManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(immersiveEnvManager)
        }
        
        WindowGroup(id: WindowDestination.myModelView1) {
            MyModelView()
        }
        WindowGroup(id: WindowDestination.myModelView2) {
            MyModelView2()
        }
        
        WindowGroup(id: WindowDestination.buttonsView) {
            ButtonsView()
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
        
        ImmersiveSpace(id: WindowDestination.remoteAssetReality) {
            RemoteAssetRealityView()
        }
        
        ImmersiveSpace(id: WindowDestination.backroomsImmersiveSpace) {
            BackroomsImmersiveSpace()
                .environment(immersiveEnvManager)
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
    static let remoteAssetReality = "remoteAssetReality"
    static let buttonsView = "buttonsView"
    static let backroomsImmersiveSpace = "BackroomsImmersiveSpace"
}
