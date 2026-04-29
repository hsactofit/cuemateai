import AppKit
import SwiftUI

@main
struct CuemateApp: App {
    @StateObject private var model = AppModel()
    @StateObject private var hotkeyManager = HotkeyManager()

    var body: some Scene {
        WindowGroup("cuemate") {
            RootView(model: model)
                .frame(minWidth: 980, minHeight: 680)
                .task {
                    await model.refreshDependencyStatuses()
                }
                .task {
                    await hotkeyManager.bind(model: model)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    model.checkScreenPermission()
                }
        }
        .commands {
            CommandMenu("Live Controls") {
                Button(model.overlayVisible ? "Hide Overlay" : "Show Overlay") {
                    model.handleHotkeyAction(.toggleOverlay)
                }
                .keyboardShortcut("H", modifiers: [.command, .shift])

                Button("Get Response") {
                    model.handleHotkeyAction(.getResponse)
                }
                .keyboardShortcut("G", modifiers: [.command, .shift])
                .disabled(model.activeMeetingSession == nil)

                Button(model.isPaused ? "Resume Scroll" : "Pause Scroll") {
                    model.handleHotkeyAction(.pauseResume)
                }
                .keyboardShortcut("P", modifiers: [.command, .shift])
                .disabled(model.activeMeetingSession == nil)

                Divider()

                Button("Next Suggestion") {
                    model.handleHotkeyAction(.nextSuggestion)
                }
                .keyboardShortcut(.rightArrow, modifiers: [.command, .shift])

                Button("Shorten Response") {
                    model.handleHotkeyAction(.shorten)
                }
                .keyboardShortcut("S", modifiers: [.command, .shift])

                Button("Expand Response") {
                    model.handleHotkeyAction(.expand)
                }
                .keyboardShortcut("L", modifiers: [.command, .shift])

                Button("More Confident") {
                    model.handleHotkeyAction(.moreConfident)
                }
                .keyboardShortcut("C", modifiers: [.command, .shift])

                Button("Regenerate") {
                    model.handleHotkeyAction(.regenerate)
                }
                .keyboardShortcut("R", modifiers: [.command, .shift])
                .disabled(model.activeMeetingSession == nil)
            }
        }

        MenuBarExtra("cuemate", systemImage: "waveform.and.mic") {
            MenuBarContentView(model: model)
                .frame(width: 320)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: model)
                .frame(width: 520, height: 420)
        }
    }
}
