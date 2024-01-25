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
    let urls: [URL] = [
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz")!,
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/tulip/flower_tulip.usdz")!,
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/wateringcan/wateringcan.usdz")!,
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/gramophone/gramophone.usdz")!,
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/pancakes/pancakes.usdz")!,
        URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/toycar/toy_car.usdz")!
    ]
    
    var body: some View {
        RealityView { _ in } update: { content in
            for entity in viewModel.modelEntities {
                content.add(entity)
            }
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged({ value in
                value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
            })
        )
        .task {
            let startTime = Date()
//            await viewModel.fetchAsset(urls: self.urls)
            await viewModel.fetchAssetFaster(urls: self.urls)
            let endTime = Date()
            let lapsed = endTime.timeIntervalSince(startTime)
            print("lalalala took \(lapsed) seconds")
        }
    }
}

@Observable
final class RemoteAssetRealityViewModel {
    var modelEntities: [ModelEntity] = []
    
    func fetchAsset(urls: [URL]) async {
        for url in urls {
            do {
                let modelEntity = try await ModelEntity(remoteURL: url)
                await modelEntity.makeTappable()
                print("lalala appending to modelEntities")
                self.modelEntities.append(modelEntity)
            } catch {
                return
            }
        }
    }
    
    func fetchAssetFaster(urls: [URL]) async {
        await withTaskGroup(of: ModelEntity?.self) { taskGroup in
            for url in urls {
                taskGroup.addTask {
                    try? await ModelEntity(remoteURL: url)
                }
            }
            
            for await modelEntityOptional in taskGroup {
                if let modelEntity = modelEntityOptional {
                    await modelEntity.makeTappable()
                    print("lalala appending to modelEntities")
                    self.modelEntities.append(modelEntity)
                }
            }
        }
    }
}

extension ModelEntity {
    convenience init(remoteURL: URL) async throws {
        print("lalalal adding task")
//        print("started downloading \(remoteURL.absoluteString)")
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
