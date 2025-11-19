//
//  ContentView.swift
//  LLMProxy
//
//  Created by Mohamed Abdulrahman on 19/11/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var runner: ProxyRunner
    
    @AppStorage("modelName") private var modelName: String = "gemini/gemini-1.5-pro"
    @AppStorage("port") private var port: String = "4000"
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("envVarName") private var envVarName: String = "GEMINI_API_KEY"
    @AppStorage("customPath") private var customPath: String = ""
    @AppStorage("useShell") private var useShell: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LLM Proxy")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Local Server Wrapper")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(isRunning: runner.isRunning)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Configuration Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Configuration", systemImage: "gearshape.fill")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                                GridRow {
                                    Text("Model:")
                                        .gridColumnAlignment(.trailing)
                                    TextField("e.g. gemini/gemini-1.5-pro", text: $modelName)
                                }
                                GridRow {
                                    Text("Port:")
                                    TextField("4000", text: $port)
                                        .frame(width: 80)
                                }
                                GridRow {
                                    Text("API Key:")
                                    SecureField("Enter API Key", text: $apiKey)
                                }
                                GridRow {
                                    Text("Env Var:")
                                    TextField("e.g. GEMINI_API_KEY", text: $envVarName)
                                }
                                GridRow {
                                    Text("Path:")
                                    TextField("Optional custom path to litellm", text: $customPath)
                                }
                                GridRow {
                                    Text("Mode:")
                                    Toggle("Run via Shell (zsh -l)", isOn: $useShell)
                                        .toggleStyle(.switch)
                                        .help("Use this if the app cannot find litellm or python environment.")
                                }
                            }
                            .disabled(runner.isRunning)
                        }
                        .padding(8)
                    }
                    .padding(.horizontal)
                    
                    // Controls
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            if runner.isRunning {
                                Button(action: { runner.stop() }) {
                                    Label("Stop Server", systemImage: "stop.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .controlSize(.large)
                            } else {
                                Button(action: {
                                    runner.start(model: modelName, port: port, apiKey: apiKey, envVarName: envVarName, customPath: customPath, useShell: useShell)
                                }) {
                                    Label("Start Server", systemImage: "play.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .controlSize(.large)
                            }
                        }
                        
                        if runner.isRunning {
                            HStack {
                                Text("Proxy URL: http://localhost:\(port)")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                                
                                Button(action: {
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString("http://localhost:\(port)", forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Copy URL")
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Logs Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Live Logs", systemImage: "terminal.fill")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            Text(runner.logs.isEmpty ? "Waiting for logs..." : runner.logs)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .background(Color.black)
                        .cornerRadius(8)
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

struct StatusBadge: View {
    let isRunning: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isRunning ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(isRunning ? "Active" : "Inactive")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isRunning ? .green : .red)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .strokeBorder(isRunning ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                .background(isRunning ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .clipShape(Capsule())
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(ProxyRunner())
}
