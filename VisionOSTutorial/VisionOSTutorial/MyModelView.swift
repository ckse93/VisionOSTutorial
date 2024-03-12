//
//  MyModelView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI
import RealityKit

struct MyModelView: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        Model3D(named: "gtr") { modelPhase in
            switch modelPhase {
            case .empty:
                ProgressView()
                    .controlSize(.extraLarge)
            case .success(let resolvedModel3D):
                resolvedModel3D
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(let error):
                Text("Fail, error: \(error.localizedDescription)")
                    .font(.largeTitle)
            default:
                Text("unknonw case")
            }
        }
        .ornament(attachmentAnchor: .scene(.topLeading)) {
            HStack {
                Button {
                    self.openWindow(id: WindowDestination.myModelView2)
                } label: {
                    Text("Open View2")
                }
                
                Button {
                    self.dismissWindow(id: WindowDestination.myModelView1)
                } label: {
                    Text("Dismiss self")
                }
            }
            .glassBackgroundEffect()
        }
    }
}

struct MyModelView2: View {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        Model3D(url: URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz")!) { modelPhase in
            switch modelPhase {
            case .empty:
                ProgressView()
                    .controlSize(.extraLarge)
            case .success(let resolvedModel3D):
                resolvedModel3D
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure(let error):
                Text("Fail, error: \(error.localizedDescription)")
                    .font(.largeTitle)
            default:
                Text("unknonw case")
            }
        }
        .ornament(attachmentAnchor: .scene(.topLeading)) {
            HStack {
                Button {
                    self.openWindow(id: WindowDestination.myModelView1)
                } label: {
                    Text("Open View1")
                }
                
                Button {
                    self.dismissWindow(id: WindowDestination.myModelView2)
                } label: {
                    Text("Dismiss self")
                }
            }
            .glassBackgroundEffect()
        }
    }
}

#Preview {
    MyModelView()
}
