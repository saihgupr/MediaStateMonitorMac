use framework "AppKit"
on run
    set MediaRemote to current application's NSBundle's bundleWithPath:"/System/Library/PrivateFrameworks/MediaRemote.framework/"
    MediaRemote's load()
    set MRNowPlayingRequest to current application's NSClassFromString("MRNowPlayingRequest")
    set appName to MRNowPlayingRequest's localNowPlayingPlayerPath()'s client()'s displayName()
    set infoDict to MRNowPlayingRequest's localNowPlayingItem()'s nowPlayingInfo()
    set title to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoTitle") as text
    set album to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoAlbum") as text
    set artist to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoArtist") as text
    set playbackRate to (infoDict's valueForKey:"kMRMediaRemoteNowPlayingInfoPlaybackRate") as real -- 1 for playing, 0 for paused/stopped
    if playbackRate = 1 then
        return "Playing: " & title & " - " & album & " - " & artist & " | " & appName
    else if title ≠ "" then
        return "Paused: " & title & " - " & album & " - " & artist & " | " & appName
    else
        return "Nothing is playing"
    end if
end run
