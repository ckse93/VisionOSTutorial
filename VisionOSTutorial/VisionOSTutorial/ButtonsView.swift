//
//  ButtonsView.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 3/8/24.
//

import SwiftUI

struct ButtonsView: View {
    var body: some View {
        HStack {
            Divider()
        }
    }
}

struct ButtonsViewTypicaliOS: View {
    var body: some View {
        VStack {
            Button {
                print("button")
            } label: {
                Text("default button")
            }
            
            Button {
                print("button")
            } label: {
                Text("plain button")
            }
            .buttonStyle(.plain)
            
            Button {
                print("button")
            } label: {
                Text("bordered button")
            }
            .buttonStyle(.bordered)
            
            Button {
                print("button")
            } label: {
                Text("bordered prominent button")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ButtonsView()
}
