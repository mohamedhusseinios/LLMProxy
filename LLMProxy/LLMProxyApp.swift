//
//  LLMProxyApp.swift
//  LLMProxy
//
//  Created by Mohamed Abdulrahman on 19/11/2025.
//

import SwiftUI

@main
struct LLMProxyApp: App {
    @StateObject private var runner = ProxyRunner()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(runner)
                .onAppear {
                    // Optional: any startup logic
                }
                .onDisappear {
                    // This might not always fire on macOS app quit, but it's a start.
                    // For macOS, we can listen to NSApplication.willTerminateNotification if needed,
                    // but StateObject deinit should trigger if the app creates it.
                    // Actually, explicit termination is safer.
                    runner.stop()
                }
        }
        // Ensure we stop the process when the window closes or app quits
        .commands {
            CommandGroup(replacing: .appTermination) {
                Button("Quit LLMProxy") {
                    runner.stop()
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
