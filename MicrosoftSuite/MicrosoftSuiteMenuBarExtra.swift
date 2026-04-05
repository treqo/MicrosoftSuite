//
//  MicrosoftSuiteMenuBarExtra.swift
//  MicrosoftSuite
//
//  Created by Tareq Alansari on 2026-04-05.
//

import SwiftUI
import WebKit

@main
struct MicrosoftLauncherApp: App {
    var body: some Scene {
        MenuBarExtra {
            AppGridView()
        } label: {
            Image("icon_16")
        }
        .menuBarExtraStyle(.window)
    }
}
