//
//  VisionOSTutorialApp.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI

@MainActor
@Observable
class AppManager {
    var mainViewState: MainView = .home
}

@main
struct VisionOSTutorialApp: App {
    @State var immersiveEnvManager = ImmersiveEnvManager()
    @State var playerModel = PlayerModel()
    @State var appManager = AppManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(immersiveEnvManager)
                .environment(playerModel)
                .environment(appManager)
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
                .onDisappear {
                    appManager.mainViewState = .home
                    immersiveEnvManager.showImmersiveSpace = false
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full) // need this otherwise docking region gets ignored
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

enum MainView {
    case video
    case home
}

struct ContentView: View {
    @Environment(PlayerModel.self) private var playerModel
    @Environment(AppManager.self) private var appManager
    @Environment(ImmersiveEnvManager.self) var immersiveEnvManager
    
    var body: some View {
        Group {
            switch appManager.mainViewState {
            case .home:
                HomeView()
                    .environment(immersiveEnvManager)
                    .environment(playerModel)
                    .environment(appManager)
            case .video:
                VideoContentView()
                    .immersiveEnvironmentPicker {
                        ImmersiveEnvironmentPickerView()
                            .environment(immersiveEnvManager)
                    }
                    .environment(immersiveEnvManager)
                    .environment(playerModel)
                    .environment(appManager)
                    .onAppear {
                        playerModel.player.play()
                    }
            }
        }
        .immersionManager()
    }
}
