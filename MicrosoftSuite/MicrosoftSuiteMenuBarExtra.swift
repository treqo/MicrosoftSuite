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
            // Microsoft Office icon from system or fallback to custom
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.Word"),
               let bundle = Bundle(url: appURL),
               let iconFile = bundle.infoDictionary?["CFBundleIconFile"] as? String {
                // Use a generic Office-style icon
                Image(systemName: "square.grid.3x3.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.orange, .red)
            } else {
                Image(systemName: "square.grid.3x3.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.orange, .red)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
