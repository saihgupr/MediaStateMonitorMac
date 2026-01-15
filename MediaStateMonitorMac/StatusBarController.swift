//
//  StatusBarController.swift
//  MediaStateMonitorMac
//
//  Created on 9/5/25.
//

import SwiftUI
import AppKit

class StatusBarController: ObservableObject {
    private var timer: Timer?
    private var lastPlayingState = false
    private var statusBarItem: NSStatusItem?
    private var popover: NSPopover?
    private var mediaController = MediaController()
    private var commandWatcher: DispatchSourceFileSystemObject?
    private let commandFilePath: String
    
    @Published var currentMediaInfo = "Loading..."
    @Published var isPlaying = false
    @Published var homeAssistantURL = ""
    @Published var bearerToken = ""
    @Published var loginItemManager = LoginItemManager()
    
    init() {
        print("StatusBarController: init called")
        
        // Setup command file path
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MediaStateMonitor")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        commandFilePath = appDir.appendingPathComponent("commands.txt").path
        
        loadSettings()
        setupStatusBar()
        startPeriodicUpdates()
        startCommandWatcher()
        print("StatusBarController: setup complete")
    }
    
    private func setupStatusBar() {
        print("StatusBarController: Setting up status bar")
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusBarItem?.button {
            print("StatusBarController: Button created")
            updateStatusBarIcon()
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        } else {
            print("StatusBarController: Failed to create button")
        }
        
        setupPopover()
        print("StatusBarController: Status bar setup complete")
    }
    
    private func updateStatusBarIcon() {
        if let button = statusBarItem?.button {
            let iconName = isPlaying ? "play.circle.fill" : "pause.circle.fill"
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Media State Monitor")
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 200)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: PopoverView(controller: self))
    }
    
    @objc private func statusBarButtonClicked() {
        print("Status bar button clicked!")
        if let popover = popover {
            if popover.isShown {
                print("Closing popover")
                popover.performClose(nil)
            } else {
                print("Showing popover")
                if let button = statusBarItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        } else {
            print("Popover is nil!")
        }
    }
    
    private func loadSettings() {
        homeAssistantURL = UserDefaults.standard.string(forKey: "homeAssistantURL") ?? ""
        bearerToken = UserDefaults.standard.string(forKey: "bearerToken") ?? ""
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(homeAssistantURL, forKey: "homeAssistantURL")
        UserDefaults.standard.set(bearerToken, forKey: "bearerToken")
    }
    
    private func startPeriodicUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateMediaInfo()
        }
        updateMediaInfo() // Initial update
    }
    
    private func updateMediaInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.launchPath = "/usr/bin/osascript"
            process.arguments = [Bundle.main.path(forResource: "getMediaInfo", ofType: "scpt") ?? ""]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                DispatchQueue.main.async {
                    let wasPlaying = self.isPlaying
                    self.currentMediaInfo = output
                    self.isPlaying = output.hasPrefix("Playing:")
                    self.updateStatusBarIcon()
                    
                    // Only send to Home Assistant if state changed
                    if wasPlaying != self.isPlaying {
                        self.sendToHomeAssistant()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    let wasPlaying = self.isPlaying
                    self.currentMediaInfo = "Error: \(error.localizedDescription)"
                    self.isPlaying = false
                    self.updateStatusBarIcon()
                    
                    // Only send to Home Assistant if state changed
                    if wasPlaying != self.isPlaying {
                        self.sendToHomeAssistant()
                    }
                }
            }
        }
    }
    
    private func sendToHomeAssistant() {
        guard !homeAssistantURL.isEmpty && !bearerToken.isEmpty else { return }
        
        let url = URL(string: "\(homeAssistantURL)/api/states/binary_sensor.mac_media_playing")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let state = isPlaying ? "on" : "off"
        let attributes = [
            "friendly_name": "Mac Media Playing",
            "device_class": "connectivity"
        ]
        
        let payload: [String: Any] = [
            "state": state,
            "attributes": attributes
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("HA API Error: \(error)")
                } else {
                    print("HA Update sent: \(state)")
                }
            }.resume()
        } catch {
            print("JSON Error: \(error)")
        }
    }
    
    func updateSettings(url: String, token: String) {
        homeAssistantURL = url
        bearerToken = token
        saveSettings()
    }
    
    private func startCommandWatcher() {
        // Create command file if it doesn't exist
        if !FileManager.default.fileExists(atPath: commandFilePath) {
            FileManager.default.createFile(atPath: commandFilePath, contents: nil)
        }
        
        // Setup file watcher
        let fileDescriptor = open(commandFilePath, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("Failed to open command file for watching")
            return
        }
        
        let queue = DispatchQueue(label: "com.mediastatemonitor.commandwatcher")
        commandWatcher = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: queue
        )
        
        commandWatcher?.setEventHandler { [weak self] in
            self?.processCommandFile()
        }
        
        commandWatcher?.setCancelHandler {
            close(fileDescriptor)
        }
        
        commandWatcher?.resume()
        print("Command watcher started at: \(commandFilePath)")
    }
    
    private func processCommandFile() {
        guard let content = try? String(contentsOfFile: commandFilePath, encoding: .utf8) else {
            return
        }
        
        let command = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        
        print("Received command: \(command)")
        
        // Clear the file
        try? "".write(toFile: commandFilePath, atomically: true, encoding: .utf8)
        
        // Execute the command
        DispatchQueue.main.async { [weak self] in
            if let mediaCommand = MediaController.MediaCommand(rawValue: command) {
                self?.mediaController.execute(mediaCommand)
            } else {
                print("Unknown command: \(command)")
            }
        }
    }
    
    func quitApp() {
        commandWatcher?.cancel()
        NSApplication.shared.terminate(nil)
    }
}

struct PopoverView: View {
    @ObservedObject var controller: StatusBarController
    @State private var showingSettings = false
    @State private var tempURL = ""
    @State private var tempToken = ""
    
    var body: some View {
        VStack(spacing: 12) {
            if showingSettings {
                settingsView
            } else {
                mainView
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
    
    private var mainView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Media State Monitor")
                    .font(.headline)
                Spacer()
                HStack(spacing: 12) {
                    Button("Settings") {
                        tempURL = controller.homeAssistantURL
                        tempToken = controller.bearerToken
                        showingSettings = true
                    }
                    .buttonStyle(.borderless)
                    
                    Button("Quit") {
                        controller.quitApp()
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Status:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(controller.currentMediaInfo)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    private var settingsView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Settings")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    controller.updateSettings(url: tempURL, token: tempToken)
                    showingSettings = false
                }
                .buttonStyle(.borderless)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Home Assistant URL:")
                        .font(.subheadline)
                    TextField("http://homeassistant.local:8123", text: $tempURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bearer Token:")
                        .font(.subheadline)
                    SecureField("Enter your HA token", text: $tempToken)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Toggle("Open at Login", isOn: $controller.loginItemManager.isEnabled)
                        .onChange(of: controller.loginItemManager.isEnabled) { _, newValue in
                            controller.loginItemManager.setLoginItem(enabled: newValue)
                        }
                    Spacer()
                }
                
            }
        }
    }
}
