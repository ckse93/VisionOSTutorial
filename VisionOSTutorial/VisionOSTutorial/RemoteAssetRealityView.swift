//
//  RemoteAssetRealityView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/22/24.
//

import ARKit
import SwiftUI
import RealityKit

struct RemoteAssetRealityView: View {
    @State var viewModel = RemoteAssetRealityViewModel()
    
    var body: some View {
        RealityView { _ in } update: { content in
            content.entities.removeAll()
            
            switch viewModel.fetchResult {
            case .loading:
                EmptyView()
            case .fail:
                EmptyView()
            case .success(let modelEntity):
                for entity in modelEntity {
                    content.add(entity)
                }
            }
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged({ value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
            })
        )
        .task {
            await viewModel.fetchAsset()
        }
    }
}

enum FetchResult {
    case loading
    case fail
    case success([ModelEntity])
}

@Observable
final class RemoteAssetRealityViewModel {
    private let arSession = ARKitSession()
    private let sceneReconstruction = SceneReconstructionProvider()
    
    var fetchResult: FetchResult = .loading
    
    func runSession() async {
        do {
            try await arSession.run([sceneReconstruction])
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    func reconstructionUpdate() async {
        for await update in sceneReconstruction.anchorUpdates {
            
        }
    }
    
    func fetchAsset() async {
        self.fetchResult = .loading
        
        guard let url = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz") else {
            self.fetchResult = .fail
            return
        }
        do {
            async let m1 = try await ModelEntity(remoteURL: URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/biplane/toy_biplane_idle.usdz")!)
            try await m1.makeTappable()
            async let modelEntity = try await ModelEntity(remoteURL: url)
            try await modelEntity.makeTappable()
            self.fetchResult = try await .success([m1, modelEntity])
        } catch {
            self.fetchResult = .fail
        }
        
    }
}

extension ModelEntity {
    convenience init(remoteURL: URL) async throws {
        
        let (data, _) = try await URLSession.shared.data(from: remoteURL)
        
        let fileURL = URL(filePath: NSTemporaryDirectory())
            .appending(path: UUID().uuidString)
            .appendingPathExtension("usdz")
        
        FileManager.default.createFile(atPath: fileURL.path(percentEncoded: false), contents: data)
        
        try await self.init(contentsOf: fileURL)
    }
}

#Preview {
    RemoteAssetRealityView()
}
