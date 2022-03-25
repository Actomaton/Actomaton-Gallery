import AVFoundation
import AVFoundation_Combine

enum PlayerAction: Sendable
{
    // AVPlayer
    case periodicTime(CMTime)
    case playingStatus(PlayingStatus)
    case playerRate(Float)

    // AVAudioSession
    case outputVolume(Float)

    // AVPlayerItem
    case playerItemStatus(AVPlayerItem.Status)
    case playerItemError(String)
    case timebaseRate(Double)
    case timeJumped
    case loadedTimeRanges([CMTimeRange])
    case seekableTimeRanges([CMTimeRange])
    case didPlayEndToTime
    case failedToPlayToEndTime(String)
    case isPlaybackLikelyToKeepUp(Bool)
    case playbackBufferState(PlaybackBufferState)
    case playbackStalled
    case timedMetadataGroups([AVTimedMetadataGroup])
    case newAccessLogEvent(AVPlayerItemAccessLogEvent)
    case newErrorLogEvent(AVPlayerItemErrorLogEvent)

    // AVAsset
    case isPlayable(Bool)
    case duration(TimeInterval)
}
