//
//  EcomApp.swift
//  Ecom
//
//  Created by MMI Softwares Pvt Ltd on 14/06/25.
//

import SwiftUI
import FirebaseCore

@main
struct EcomApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured: \(FirebaseApp.app() != nil)")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

