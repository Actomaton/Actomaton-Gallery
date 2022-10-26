import AVFoundation

// MARK: - LogEvent descriptionDictionary

extension AVPlayerItemAccessLogEvent
{
    public var descriptionDictionary: [String: Any]
    {
        var output = [String: Any]()
        output["numberOfMediaRequests"] = numberOfMediaRequests
        output["playbackStartDate"] = playbackStartDate?.description ?? ""
        output["uri"] = uri ?? ""
        output["serverAddress"] = serverAddress ?? ""
        output["numberOfServerAddressChanges"] = numberOfServerAddressChanges
        output["playbackSessionID"] = playbackSessionID ?? ""
        output["playbackStartOffset"] = playbackStartOffset
        output["segmentsDownloadedDuration"] = segmentsDownloadedDuration
        output["durationWatched"] = durationWatched
        output["numberOfStalls"] = numberOfStalls
        output["numberOfBytesTransferred"] = Int(numberOfBytesTransferred)
        output["transferDuration"] = transferDuration
        output["observedBitrate"] = observedBitrate
        output["indicatedBitrate"] = indicatedBitrate
        output["numberOfDroppedVideoFrames"] = numberOfDroppedVideoFrames
        output["startupTime"] = startupTime
        output["downloadOverdue"] = downloadOverdue
        output["observedMaxBitrate"] = observedMaxBitrate
        output["observedMinBitrate"] = observedMinBitrate
        output["observedBitrateStandardDeviation"] = observedBitrateStandardDeviation
        output["playbackType"] = playbackType
        output["mediaRequestsWWAN"] = mediaRequestsWWAN
        output["switchBitrate"] = switchBitrate
        return output
    }
}

extension AVPlayerItemErrorLogEvent
{
    public var descriptionDictionary: [String: Any]
    {
        var output = [String: Any]()
        output["date"] = date ?? ""
        output["uri"] = uri ?? ""
        output["serverAddress"] = serverAddress ?? ""
        output["playbackSessionID"] = playbackSessionID ?? ""
        output["errorStatusCode"] = errorStatusCode
        output["errorDomain"] = errorDomain
        output["errorComment"] = errorComment ?? ""
        return output
    }
}

// MARK: - Log extendedLogString

extension AVPlayerItemAccessLog
{
    open var extendedLogString: String?
    {
        guard let data = extendedLogData(),
              let string = String(data: data, encoding: .init(rawValue: extendedLogDataStringEncoding))
        else { return nil }

        return string
    }
}

extension AVPlayerItemErrorLog
{
    open var extendedLogString: String?
    {
        guard let data = extendedLogData(),
              let string = String(data: data, encoding: .init(rawValue: extendedLogDataStringEncoding))
        else { return nil }

        return string
    }
}

extension AVMutableComposition
{
    /// Adds a new track with composing multiple `assets` (videos, audios) in sequence.
    /// https://gist.github.com/Moligaloo/7b0de3722d8655a30c7abe8b7b21becc
    public func composeAssetsInSequence<Assets>(
        _ assets: Assets,
        mediaType: AVMediaType,
        totalDuration: CMTime = .positiveInfinity
    ) throws
        where Assets: Sequence, Assets.Element: AVAsset
    {
        guard let compositionTrack = addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }

        var time = CMTime.zero
        for asset in assets {
            if time > totalDuration { break }

            guard let assetTrack = asset.tracks(withMediaType: mediaType).first else { continue }

            if mediaType == .video, time == .zero {
                compositionTrack.preferredTransform = assetTrack.preferredTransform
            }

            let nextTime = CMTimeAdd(time, asset.duration)

            let shouldTrim = nextTime > totalDuration

            let assetDuration: CMTime

            if shouldTrim {
                assetDuration = CMTimeSubtract(totalDuration, time)
            } else {
                assetDuration = asset.duration
            }

            try compositionTrack.insertTimeRange(
                .init(start: .zero, duration: assetDuration),
                of: assetTrack,
                at: time
            )
            time = CMTimeAdd(time, asset.duration)
        }
    }
}
