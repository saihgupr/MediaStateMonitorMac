//
//  ContentView.swift
//  MediaStateMonitorMac
//
//  Created on 9/5/25.
//

import SwiftUI
import OSLog

struct ContentView: View {
    @State private var mediaInfo = "Loading..."
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Media State Monitor")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(mediaInfo)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Button(action: refreshMediaInfo) {
                HStack {
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Refresh")
                }
            }
            .disabled(isRefreshing)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
        .onAppear {
            refreshMediaInfo()
        }
    }
    
    private func refreshMediaInfo() {
        isRefreshing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Use the compiled AppleScript file
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
                    if !output.isEmpty {
                        self.mediaInfo = output
                    } else {
                        self.mediaInfo = "Error getting media info"
                    }
                    self.isRefreshing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.mediaInfo = "Error: \(error.localizedDescription)"
                    self.isRefreshing = false
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
