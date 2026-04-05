//
//  MicrosoftSuiteMenuBarExtra.swift
//  MicrosoftSuite
//
//  Created by Tareq Alansari on 2026-04-05.
//

import SwiftUI

@main
struct MicrosoftLauncherApp: App {
    var body: some Scene {
        MenuBarExtra {
            AppGridView()
        } label: {
            Image(systemName: "square.grid.3x3.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.orange, .red)
        }
        .menuBarExtraStyle(.window)
    }
}
