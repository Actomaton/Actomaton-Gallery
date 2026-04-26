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
    public var extendedLogString: String?
    {
        guard let data = extendedLogData(),
              let string = String(data: data, encoding: .init(rawValue: extendedLogDataStringEncoding))
        else { return nil }

        return string
    }
}

extension AVPlayerItemErrorLog
{
    public var extendedLogString: String?
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
    ) async throws
        where Assets: Sequence, Assets.Element: AVAsset
    {
        guard let compositionTrack = addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }

        var time = CMTime.zero
        for asset in assets {
            if time > totalDuration { break }

            guard let assetTrack = try await asset.loadTracks(withMediaType: mediaType).first else { continue }

            if mediaType == .video, time == .zero {
                compositionTrack.preferredTransform = try await assetTrack.load(.preferredTransform)
            }

            let assetDuration = try await asset.load(.duration)
            let nextTime = CMTimeAdd(time, assetDuration)

            let shouldTrim = nextTime > totalDuration

            let insertDuration: CMTime
            if shouldTrim {
                insertDuration = CMTimeSubtract(totalDuration, time)
            } else {
                insertDuration = assetDuration
            }

            try compositionTrack.insertTimeRange(
                .init(start: .zero, duration: insertDuration),
                of: assetTrack,
                at: time
            )
            time = CMTimeAdd(time, assetDuration)
        }
    }
}
