//
//  MacUninstallerApp.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import SwiftUI
import SwiftData

@main
struct MacUninstallerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentSize)
    }
}
