//
//  ContentView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI
import RealityKit
struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(ImmersiveEnvManager.self) var immersiveEnvManager

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        VStack {
            Button {
                self.openWindow(id: WindowDestination.buttonsView)
            } label: {
                Text("open Buttons View")
            }
            Button {
                self.openWindow(id: WindowDestination.myModelView1)
            } label: {
                Text("open myModelView1")
            }
            Button {
                self.openWindow(id: WindowDestination.myModelView2)
            } label: {
                Text("open myModelView2")
            }
            
            Text("Hello, world!")

            Toggle("Show Immersive Space", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding(.top, 50)
            
            Button {
                Task {
                    await self.openImmersiveSpace(id: WindowDestination.remoteAssetReality)
                }
            } label: {
                Text("remote asset reality view")
            }
            
            Button {
                Task {
                    await self.dismissImmersiveSpace()
                }
            } label: {
                Text("Dismiss immersive space")
            }
            
            Button {
                Task {
                    await immersiveEnvManager.loadAsset()
                    await self.openImmersiveSpace(id: WindowDestination.backroomsImmersiveSpace)
                }
            } label: {
                Text("Open Backrooms")
            }
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
