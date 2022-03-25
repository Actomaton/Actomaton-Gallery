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
