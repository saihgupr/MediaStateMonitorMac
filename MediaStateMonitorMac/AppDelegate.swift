//
//  AppDelegate.swift
//  MediaStateMonitorMac
//
//  Created on 9/5/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching called")
        // Setup status bar controller
        statusBarController = StatusBarController()
        print("AppDelegate: StatusBarController created")
    }
}
