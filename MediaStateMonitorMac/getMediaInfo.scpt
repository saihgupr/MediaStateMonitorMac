use framework "AppKit"

on run
    try
        -- Try the MediaRemote approach with better error handling
        set result to getMediaInfoFromMediaRemote()
        if result is not "Nothing is playing" then
            return result
        end if
    end try
    
    try
        -- Try checking specific media apps
        set result to getMediaInfoFromApps()
        if result is not "Nothing is playing" then
            return result
        end if
    end try
    
    return "Nothing is playing"
end run

on getMediaInfoFromMediaRemote()
    try
        set MediaRemote to current application's NSBundle's bundleWithPath:"/System/Library/PrivateFrameworks/MediaRemote.framework/"
        MediaRemote's load()
        set MRNowPlayingRequest to current application's NSClassFromString("MRNowPlayingRequest")
        
        -- Try to get app name with better error handling
        set appName to "Unknown App"
        try
            set playerPath to MRNowPlayingRequest's localNowPlayingPlayerPath()
            if playerPath is not missing value then
                set client to playerPath's client()
                if client is not missing value then
                    try
                        set appName to client's displayName()
                    on error
                        -- If displayName fails, try other methods
                        try
                            set appName to client's bundleIdentifier()
                        on error
                            set appName to "Media App"
                        end try
                    end try
                end if
            end if
        end try
        
        set infoDict to MRNowPlayingRequest's localNowPlayingItem()'s nowPlayingInfo()
        if infoDict is not missing value then
            set title to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoTitle") as text
            set album to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoAlbum") as text
            set artist to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoArtist") as text
            set playbackRate to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoPlaybackRate") as real
            
            if playbackRate = 1 then
                return "Playing: " & title & " - " & album & " - " & artist & " | " & appName
            else if title ≠ "" then
                return "Paused: " & title & " - " & album & " - " & artist & " | " & appName
            end if
        end if
    end try
    return "Nothing is playing"
end getMediaInfoFromMediaRemote

on getMediaInfoFromApps()
    try
        -- Check Music app only if it's already running
        tell application "System Events"
            if exists process "Music" then
                tell application "Music"
                    if player state is playing then
                        set currentTrack to current track
                        set trackName to name of currentTrack
                        set artistName to artist of currentTrack
                        set albumName to album of currentTrack
                        return "Playing: " & trackName & " - " & albumName & " - " & artistName & " | Music"
                    else if player state is paused then
                        set currentTrack to current track
                        set trackName to name of currentTrack
                        set artistName to artist of currentTrack
                        set albumName to album of currentTrack
                        return "Paused: " & trackName & " - " & albumName & " - " & artistName & " | Music"
                    end if
                end tell
            end if
        end tell
    end try
    
    try
        -- Check Spotify (if running)
        tell application "System Events"
            if exists process "Spotify" then
                tell process "Spotify"
                    if frontmost then
                        -- Spotify is active, try to get info
                        return "Playing: Spotify | Spotify"
                    end if
                end tell
            end if
        end tell
    end try
    
    try
        -- Check YouTube (if running)
        tell application "System Events"
            if exists process "Google Chrome" then
                tell process "Google Chrome"
                    if frontmost then
                        -- Check if YouTube tab is active
                        return "Playing: YouTube | Chrome"
                    end if
                end tell
            end if
        end tell
    end try
    
    return "Nothing is playing"
end getMediaInfoFromApps