# MediaStateMonitorMac

![MediaStateMonitorMac Screenshot](https://i.imgur.com/wr5PJA5.png)

A macOS status bar application that monitors and displays the current media playback state on your Mac. This app provides real-time information about what music, video, or other media is currently playing across all applications.

## What It Does

MediaStateMonitorMac sits in your macOS status bar and continuously monitors media playback across your system. It can detect and display information about:

- **Currently playing music** (Spotify, Apple Music, iTunes, etc.)
- **Video playback** (YouTube, Netflix, VLC, QuickTime, etc.)
- **Podcast apps** (Overcast, Pocket Casts, etc.)
- **Any media application** that uses system media controls

The app uses AppleScript integration to query the current media state and displays the information in a clean, minimal status bar interface.

## Features

- **Real-time media monitoring** - Detects what's playing across all apps
- **Status bar integration** - Clean, unobtrusive status bar display
- **Auto-start capability** - Can be set to launch automatically on login
- **System-wide detection** - Works with any media application
- **Lightweight** - Minimal system resource usage

## Requirements

- macOS 10.15 or later
- Xcode 12.0 or later
- Swift 5.0 or later

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/saihgupr/MediaStateMonitorMac.git
   ```

2. Open `MediaStateMonitorMac.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

4. The app will appear in your status bar and begin monitoring media state

## Usage

Once running, MediaStateMonitorMac will automatically detect and display information about any media currently playing on your system. Click the status bar icon to see current media information or access settings.

## Technical Details

The app uses AppleScript to query the current media state through system APIs, allowing it to detect playback information from virtually any media application on macOS.

## License

This project is available for personal use.
