import Foundation
import AVFoundation
import Combine
import AVFoundation_Combine

/// `AVPlayer` state representation for debuggable demo with reflection-printing via ``mirroredChildren``.
struct PlayerState: Equatable, Sendable
{
    var assetInitTime: TimeInterval = 0
    var playerItemInitTime: TimeInterval = 0
    var playerItemReplacedTime: TimeInterval = 0

    var playerItemStatus: AVPlayerItem.Status = .unknown
    var playingStatus: PlayingStatus = .unknown
    var isPlayable: Bool = false
    var playbackBufferState: PlaybackBufferState = .empty
    var isPlaybackLikelyToKeepUp: Bool = false
    var loadedTimeRanges: [CMTimeRange] = []
    var seekableTimeRanges: [CMTimeRange] = []

    var currentTime: TimeInterval = .nan
    var duration: TimeInterval = .nan
    var playerRate: Float = .nan
    var timebaseRate: Double = .nan
    var outputVolume: Float = .nan
    var errorString: String?

    var playbackStalled: Notification?
    var timedMetadataGroups: [AVTimedMetadataGroup] = []
    var newAccessLogEvent: String? // AVPlayerItemAccessLogEvent?
    var newErrorLogEvent: String?  // AVPlayerItemErrorLogEvent?

    var mirroredChildren: [(label: String, value: String)]
    {
        Mirror(reflecting: self).children
            .compactMap { label, value in
                label.map { ($0, String(describing: value)) }
            }
            .map { label, value in
                let value2 = value.replacingOccurrences(
                    of: "Optional\\((.*)\\)",
                    with: "$1",
                    options: .regularExpression
                )
                guard let value1 = Double(value2) else {
                    return (label, value2)
                }
                // If value is floating point, use `shortFloatingDescription`.
                return (label, value1.shortFloatingDescription)
            }
    }
}

extension FloatingPoint
{
    fileprivate var shortFloatingDescription: String
    {
        let factor: Self = 10000
        let value = (self * factor).rounded() / factor
        return "\(value)"
    }
}
