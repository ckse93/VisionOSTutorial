//
//  VisionOSTutorialApp.swift
//  VisionOSTutorial
//
//  Created by Chan Jung on 12/8/23.
//

import SwiftUI

@main
struct VisionOSTutorialApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        WindowGroup(id: WindowDestination.myModelView1) {
            MyModelView()
        }
        WindowGroup(id: WindowDestination.myModelView2) {
            MyModelView2()
        }
//        WindowGroup(id: "MyView3") {
//            MyView3()
//        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}


struct WindowDestination {
    static let myModelView1 = "myModelView1"
    static let myModelView2 = "myModelView2"
    static let myModelView3 = "myModelView3"
}
