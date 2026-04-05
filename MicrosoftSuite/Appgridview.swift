//
//  Appgridview.swift
//  MicrosoftSuite
//
//  Created by Tareq Alansari on 2026-04-05.
//

import SwiftUI

struct MicrosoftApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let fallbackIcon: String
    let accentColor: Color
}

let microsoftApps: [MicrosoftApp] = [
    MicrosoftApp(name: "Word",       bundleID: "com.microsoft.Word",                fallbackIcon: "doc.fill",           accentColor: Color(red: 0.16, green: 0.44, blue: 0.78)),
    MicrosoftApp(name: "Excel",      bundleID: "com.microsoft.Excel",               fallbackIcon: "tablecells.fill",     accentColor: Color(red: 0.13, green: 0.54, blue: 0.34)),
    MicrosoftApp(name: "PowerPoint", bundleID: "com.microsoft.Powerpoint",          fallbackIcon: "rectangle.on.rectangle.fill", accentColor: Color(red: 0.84, green: 0.33, blue: 0.18)),
    MicrosoftApp(name: "Outlook",    bundleID: "com.microsoft.Outlook",             fallbackIcon: "envelope.fill",       accentColor: Color(red: 0.0,  green: 0.47, blue: 0.83)),
    MicrosoftApp(name: "Teams",      bundleID: "com.microsoft.teams",               fallbackIcon: "person.2.fill",       accentColor: Color(red: 0.29, green: 0.21, blue: 0.60)),
    MicrosoftApp(name: "OneNote",    bundleID: "com.microsoft.onenote.mac",         fallbackIcon: "note.text",           accentColor: Color(red: 0.50, green: 0.20, blue: 0.60)),
    MicrosoftApp(name: "OneDrive",   bundleID: "com.microsoft.OneDrive",            fallbackIcon: "cloud.fill",          accentColor: Color(red: 0.0,  green: 0.47, blue: 0.83)),
    MicrosoftApp(name: "Edge",       bundleID: "com.microsoft.edgemac",             fallbackIcon: "globe",               accentColor: Color(red: 0.0,  green: 0.60, blue: 0.53)),
]

struct AppGridView: View {
    let columns = [
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
    ]

    var installedApps: [MicrosoftApp] {
        microsoftApps.filter {
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0.bundleID) != nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Microsoft")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Quit launcher")
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 8)

            // App Grid
            if installedApps.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "app.dashed")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No Microsoft apps found")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(installedApps) { app in
                        AppIconButton(app: app)
                    }
                }
                .padding(16)
            }
        }
        .frame(width: 380)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct AppIconButton: View {
    let app: MicrosoftApp
    @State private var isHovered = false
    @State private var isPressed = false

    var appIcon: NSImage? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }

    var body: some View {
        Button(action: {
            launch()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isHovered ? app.accentColor.opacity(0.15) : Color.clear)
                        .frame(width: 60, height: 60)

                    if let icon = appIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(app.accentColor)
                                .frame(width: 48, height: 48)
                            Image(systemName: app.fallbackIcon)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }

                Text(app.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isHovered ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.90 : (isHovered ? 1.05 : 1.0))
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHovered)
        .animation(.spring(response: 0.15, dampingFraction: 0.7), value: isPressed)
        .onHover { hovering in
            isHovered = hovering
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    func launch() {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleID) else { return }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
}
