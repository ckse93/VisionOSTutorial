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
