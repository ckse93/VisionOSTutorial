//
//  VideoView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/6/25.
//

import SwiftUI
import AVKit

@MainActor
@Observable
class PlayerModel {
    var player = AVPlayer()
    
    func makePlayerUI() -> AVPlayerViewController {
        guard let url = Bundle.main.url(forResource: "lightsabersample", withExtension: "mp4") else {
            fatalError("Unable to locate the Demo movie file, make sure you supple it.")
        }
        let avPlayerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: avPlayerItem)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}

struct VideoContentView: UIViewControllerRepresentable {
    @Environment(PlayerModel.self) private var model
    @Environment(AppManager.self) private var appManager
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = model.makePlayerUI()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct ImmersiveEnvironmentPickerView: View {
    @Environment(ImmersiveEnvManager.self) var immersiveEnvManager
    
    var body: some View {
        Button {
            Task {
                await immersiveEnvManager.loadAsset()
                immersiveEnvManager.presentImmersiveSpace()
            }
        } label: {
            Label {
                Text("Backroom", comment: "backroom")
            } icon: {
                Image("icon")  // these images should be 180 x 180 pixel smh
            }
        }
    }
}

extension View {
    func immersionManager() -> some View {
        self.modifier(ImmersiveSpacePresentationModifier())
    }
}

private struct ImmersiveSpacePresentationModifier: ViewModifier {
    @Environment(ImmersiveEnvManager.self) var immersiveEnvManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    func body(content: Content) -> some View {
        content
            .onChange(of: immersiveEnvManager.showImmersiveSpace) { _, show in
                Task { @MainActor in
                    if show {
                        await openImmersiveSpace(id: WindowDestination.backroomsImmersiveSpace)
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
    }
}
