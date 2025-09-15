//
//  MediaStateMonitorMacApp.swift
//  MediaStateMonitorMac
//
//  Created by Chris LaPointe on 9/5/25.
//

import SwiftUI

@main
struct MediaStateMonitorMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
