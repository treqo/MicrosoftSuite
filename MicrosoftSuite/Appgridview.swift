//
//  AppGridView.swift
//  MicrosoftSuite
//

import SwiftUI

struct MicrosoftApp: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    let icon: NSImage
}

// Apps to exclude even if they have a com.microsoft. bundle ID
let excludedBundleIDs: Set<String> = [
    "com.microsoft.autoupdate2",
    "com.microsoft.autoupdate.fba",
    "com.microsoft.package.Microsoft_AutoUpdate_App",
    "com.microsoft.remotedesktopagent",
    "com.microsoft.teams.background",
    "com.microsoft.VSCode",
]

func discoverMicrosoftApps() -> [MicrosoftApp] {
    let fileManager = FileManager.default
    let searchPaths = [
        "/Applications",
        "\(NSHomeDirectory())/Applications"
    ]

    var found: [MicrosoftApp] = []
    var seenBundleIDs = Set<String>()

    for path in searchPaths {
        guard let items = try? fileManager.contentsOfDirectory(atPath: path) else { continue }

        for item in items where item.hasSuffix(".app") {
            let appPath = "\(path)/\(item)"
            let appURL = URL(fileURLWithPath: appPath)

            guard
                let bundle = Bundle(url: appURL),
                let bundleID = bundle.bundleIdentifier,
                bundleID.lowercased().hasPrefix("com.microsoft."),
                !excludedBundleIDs.contains(bundleID),
                !seenBundleIDs.contains(bundleID)
            else { continue }

            seenBundleIDs.insert(bundleID)

            // Prefer CFBundleDisplayName, then CFBundleName, then filename
            let displayName = (bundle.infoDictionary?["CFBundleDisplayName"] as? String)
                ?? (bundle.infoDictionary?["CFBundleName"] as? String)
                ?? item.replacingOccurrences(of: ".app", with: "")

            // Strip "Microsoft " prefix for cleaner labels (e.g. "Microsoft Word" → "Word")
            let shortName = displayName.hasPrefix("Microsoft ")
                ? String(displayName.dropFirst("Microsoft ".count))
                : displayName

            let icon = NSWorkspace.shared.icon(forFile: appPath)
            icon.size = NSSize(width: 64, height: 64)

            found.append(MicrosoftApp(name: shortName, url: appURL, icon: icon))
        }
    }

    return found.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
}

struct AppGridView: View {
    @State private var apps: [MicrosoftApp] = []

    let columns = [
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
        GridItem(.fixed(80), spacing: 16),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Microsoft")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .help("Refresh app list")

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

            if apps.isEmpty {
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
                    ForEach(apps) { app in
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
        .onAppear { refresh() }
    }

    func refresh() {
        apps = discoverMicrosoftApps()
    }
}

struct AppIconButton: View {
    let app: MicrosoftApp
    @State private var isHovered = false
    @State private var isPressed = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { launch() }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isHovered ? Color.accentColor.opacity(0.12) : Color.clear)
                        .frame(width: 60, height: 60)

                    Image(nsImage: app.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
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
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    func launch() {
        NSWorkspace.shared.openApplication(at: app.url, configuration: NSWorkspace.OpenConfiguration())
        dismiss()
    }
}
