//
//  LoginItemManager.swift
//  MediaStateMonitorMac
//
//  Created by Chris LaPointe on 9/5/25.
//

import Foundation
import ServiceManagement

class LoginItemManager: ObservableObject {
    @Published var isEnabled: Bool = false
    
    private let loginItemIdentifier = "com.pizzaman.MediaStateMonitorMac"
    
    init() {
        checkLoginItemStatus()
    }
    
    func checkLoginItemStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }
    
    func setLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            isEnabled = enabled
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") login item: \(error)")
        }
    }
}
