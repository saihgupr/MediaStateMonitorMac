//
//  MediaController.swift
//  MediaStateMonitorMac
//
//  Created on 1/15/26.
//

import Foundation
import AppKit

class MediaController {
    
    enum MediaCommand: String {
        case play
        case pause
        case playPause
        case next
        case previous
    }
    
    /// Execute a media control command
    func execute(_ command: MediaCommand) {
        let script: String
        
        switch command {
        case .play:
            script = """
            tell application "System Events"
                key code 126 using {command down}
            end tell
            """
        case .pause:
            script = """
            tell application "System Events"
                key code 125 using {command down}
            end tell
            """
        case .playPause:
            script = """
            tell application "System Events"
                keystroke " " using {command down, shift down}
            end tell
            """
        case .next:
            script = """
            tell application "System Events"
                key code 124 using {command down}
            end tell
            """
        case .previous:
            script = """
            tell application "System Events"
                key code 123 using {command down}
            end tell
            """
        }
        
        executeAppleScript(script)
    }
    
    private func executeAppleScript(_ script: String) {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            } else {
                print("Successfully executed media command")
            }
        }
    }
}
