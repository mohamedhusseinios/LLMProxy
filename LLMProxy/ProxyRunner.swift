import Foundation
import Combine

class ProxyRunner: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var logs: String = ""
    @Published var errorMessage: String? = nil
    
    private var process: Process?
    private var outputPipe: Pipe?
    private var errorPipe: Pipe?
    
    init() {}
    
    func start(model: String, port: String, apiKey: String, envVarName: String, customPath: String = "", useShell: Bool = false) {
        guard !isRunning else { return }
        
        // 1. Find litellm executable (skip if using shell, as we rely on shell PATH)
        var executablePath = ""
        if !useShell {
            guard let path = findLiteLLMPath(customPath: customPath) else {
                appendLog("Error: Could not find 'litellm' executable. Please install it or specify the path manually.")
                return
            }
            executablePath = path
            appendLog("Found litellm at: \(executablePath)")
        }
        
        appendLog("Starting litellm with model: \(model) on port: \(port)...")
        if useShell {
            appendLog("Mode: Shell Execution (zsh -l)")
        }
        
        // 2. Configure Process
        let process = Process()
        
        if useShell {
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            // Construct the command string. We need to handle quotes carefully.
            // Using -l to load user profile (PATH, aliases, etc.)
            let cmd = "litellm --model \"\(model)\" --port \(port)"
            process.arguments = ["-c", "-l", cmd]
        } else {
            process.executableURL = URL(fileURLWithPath: executablePath)
            process.arguments = ["--model", model, "--port", port]
        }
        
        // 3. Set Environment Variables
        var env = ProcessInfo.processInfo.environment
        if !envVarName.isEmpty && !apiKey.isEmpty {
            env[envVarName] = apiKey
        }
        
        if !useShell {
            // Ensure PATH includes common locations for dependencies when NOT using shell
            let currentPath = env["PATH"] ?? ""
            let newPath = currentPath + ":/usr/local/bin:/opt/homebrew/bin:/Users/\(NSUserName())/.local/bin"
            env["PATH"] = newPath
        }
        
        process.environment = env
        
        // 4. Setup Pipes
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        
        self.outputPipe = outPipe
        self.errorPipe = errPipe
        self.process = process
        
        // 5. Handle Output
        outPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async {
                    self?.appendLog(str)
                }
            }
        }
        
        errPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                DispatchQueue.main.async {
                    self?.appendLog(str)
                }
            }
        }
        
        process.terminationHandler = { [weak self] proc in
            DispatchQueue.main.async {
                self?.isRunning = false
                self?.appendLog("Process terminated with status: \(proc.terminationStatus)")
                self?.process = nil
                self?.outputPipe = nil
                self?.errorPipe = nil
            }
        }
        
        // 6. Run
        do {
            try process.run()
            self.isRunning = true
        } catch {
            appendLog("Failed to start process: \(error.localizedDescription)")
            appendLog("Troubleshooting: Ensure App Sandbox is disabled in Xcode 'Signing & Capabilities'.")
            self.isRunning = false
        }
    }
    
    func stop() {
        guard isRunning, let process = process else { return }
        appendLog("Stopping server...")
        process.terminate()
    }
    
    private func findLiteLLMPath(customPath: String) -> String? {
        if !customPath.isEmpty {
            // If user provided a path, check if it exists
            if FileManager.default.fileExists(atPath: customPath) {
                return customPath
            } else {
                appendLog("Warning: Custom path '\(customPath)' does not exist.")
            }
        }
        
        let commonPaths = [
            "/usr/local/bin/litellm",
            "/opt/homebrew/bin/litellm",
            "/Users/\(NSUserName())/.local/bin/litellm"
        ]
        
        for path in commonPaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
    private func appendLog(_ message: String) {
        logs += message + "\n"
    }
}
