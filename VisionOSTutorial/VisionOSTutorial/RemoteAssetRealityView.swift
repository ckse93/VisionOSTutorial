//
//  RemoteAssetRealityView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 1/22/24.
//

import SwiftUI
import RealityKit

struct RemoteAssetRealityView: View {
    @State var viewModel = RemoteAssetRealityViewModel()
    
    var body: some View {
        RealityView { _ in } update: { content in
            switch viewModel.fetchResult {
            case .loading:
                EmptyView()
            case .fail:
                EmptyView()
            case .success(let modelEntity):
                content.add(modelEntity)
            }
        }
        .task {
            await viewModel.fetchAsset()
        }
    }
}

enum FetchResult {
    case loading
    case fail
    case success(ModelEntity)
}

@Observable
final class RemoteAssetRealityViewModel {
    var fetchResult: FetchResult = .loading
    
    func fetchAsset() async {
        self.fetchResult = .loading
        
        guard let url = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz") else {
            self.fetchResult = .fail
            return
        }
        do {
            let modelEntity = try await ModelEntity(remoteURL: url)
            self.fetchResult = .success(modelEntity)
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
