# MediaStateMonitor

![MediaStateMonitor Screenshot](https://i.imgur.com/wr5PJA5.png)

Get real-time information about what music, video, or other media is currently playing across all applications, and automatically sync this data to Home Assistant as a binary sensor for seamless smart home automation.

## What It Does

MediaStateMonitor sits in your macOS status bar and continuously monitors media playback across your system. It can detect and display information about:

- **Currently playing music** (Spotify, Apple Music, iTunes, etc.)
- **Video playback** (YouTube, Netflix, VLC, QuickTime, etc.)
- **Podcast apps** (Overcast, Pocket Casts, etc.)
- **Any media application** that uses system media controls

Then it sends the media state as a binary sensor to Home Assistant, specifically the `binary_sensor.mac_media_playing` entity. If it doesn’t already exist, it will create it.

## Features

- **Real-time media monitoring** - Detects what's playing across all apps
- **CLI media controls** - Control playback remotely via command-line interface
- **Status bar integration** - Clean, unobtrusive status bar display
- **Home Assistant integration** - Sends media state as a binary sensor to Home Assistant
- **Auto-start capability** - Can be set to launch automatically on login
- **System-wide detection** - Works with any media application
- **Lightweight** - Minimal system resource usage

## Requirements

- macOS 10.15 or later
- Xcode 12.0 or later
- Swift 5.0 or later

## Installation

### Option 1: Download from Releases (Recommended)
Download the latest version from the [releases](https://github.com/saihgupr/MediaStateMonitorMac/releases) page and run the app directly.

### Option 2: Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/saihgupr/MediaStateMonitorMac.git
   ```

2. Open `MediaStateMonitor.xcodeproj` in Xcode

3. Build and run the project (⌘+R)

4. The app will appear in your status bar and begin monitoring media state

## Usage

![MediaStateMonitor Usage Screenshot](https://i.imgur.com/ICl6zVP.png)

Once running, MediaStateMonitor will automatically detect and display information about any media currently playing on your system. Click the status bar icon to see current media information or access settings.

## CLI Media Controls

Control your Mac's media playback remotely using the included `mediactl` command-line tool.

### Available Commands

```bash
./mediactl play         # Resume playback
./mediactl pause        # Pause playback
./mediactl playpause     # Toggle play/pause
./mediactl next         # Skip to next track
./mediactl previous     # Go to previous track
```

### Installation for System-Wide Access

To use `mediactl` from anywhere in your terminal:

```bash
sudo cp mediactl /usr/local/bin/
```

Then you can simply run:

```bash
mediactl play
mediactl next
```

The CLI controls work with any media application that responds to macOS system media keys.

## Technical Details

The app uses AppleScript to query the current media state through system APIs, allowing it to detect playback information from virtually any media application on macOS.

## License

This project is available for personal use.
