//
//  MediaController.swift
//  MediaStateMonitorMac
//
//  Created on 1/15/26.
//

import Foundation

class MediaController {
    
    enum MediaCommand: String {
        case play
        case pause
        case playpause
        case next
        case previous
    }
    
    // MRMediaRemote command constants
    private let kMRPlay: Int32 = 0
    private let kMRPause: Int32 = 1
    private let kMRTogglePlayPause: Int32 = 2
    private let kMRNextTrack: Int32 = 4
    private let kMRPreviousTrack: Int32 = 5
    
    private typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int32, AnyObject?) -> Bool
    private var sendCommand: MRMediaRemoteSendCommandFunction?
    
    init() {
        setupMediaRemote()
    }
    
    private func setupMediaRemote() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"
        guard let handle = dlopen(path, RTLD_LAZY) else {
            print("MediaController: Failed to open MediaRemote at \(path)")
            return
        }
        
        guard let sym = dlsym(handle, "MRMediaRemoteSendCommand") else {
            print("MediaController: Failed to find MRMediaRemoteSendCommand symbol")
            return
        }
        
        self.sendCommand = unsafeBitCast(sym, to: MRMediaRemoteSendCommandFunction.self)
        print("MediaController: MediaRemote setup successfully")
    }
    
    /// Execute a media control command
    func execute(_ command: MediaCommand) {
        guard let sendCommand = self.sendCommand else {
            print("MediaController: MediaRemote not initialized")
            return
        }
        
        let mrCommand: Int32
        switch command {
        case .play: mrCommand = kMRPlay
        case .pause: mrCommand = kMRPause
        case .playpause: mrCommand = kMRTogglePlayPause
        case .next: mrCommand = kMRNextTrack
        case .previous: mrCommand = kMRPreviousTrack
        }
        
        let result = sendCommand(mrCommand, NSDictionary())
        print("MediaController: Sent \(command.rawValue) (\(mrCommand)), result: \(result)")
    }
}
