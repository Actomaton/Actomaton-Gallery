import AVFoundation
import Combine
import SwiftUI
import AVFoundation_Combine
import ActomatonUI
import ActomatonDebugging

// MARK: - Reducer

func rootReducer() -> Reducer<RootAction, RootState, RootEnvironment>
{
    Reducer { action, state, environment in
        switch action {
        case .reloadRandom:
            return Effect {
                switch environment.testMode {
                case let .single(videoURL):
                    guard let url = videoURL() else { return nil }

                    let startTime = CFAbsoluteTimeGetCurrent()
                    let asset = AVAsset(url: url)
                    let assetInitTime = CFAbsoluteTimeGetCurrent() - startTime

                    return RootAction._reload((asset, assetInitTime: assetInitTime))

                case let .composition(videoURLs):
                    let urls = videoURLs()
                    let assets = urls.map(AVAsset.init(url:))

                    let startTime = CFAbsoluteTimeGetCurrent()

                    let composition: AVComposition = try {
                        let composition = AVMutableComposition()
                        try composition.composeAssetsInSequence(assets, mediaType: .video)
                        try composition.composeAssetsInSequence(assets, mediaType: .audio)
                        return composition
                    }()

                    let assetInitTime = CFAbsoluteTimeGetCurrent() - startTime

                    return RootAction._reload((composition, assetInitTime: assetInitTime))
                }
            }

        case let ._reload(args?):
            let (asset, assetInitTime) = args
            let wasPaused = state.playerState.playingStatus == .paused

            state.playerState.playingStatus = .paused

            return Effect.nextAction(.pause)
                + Effect { @MainActor in
                    guard let player = environment.getPlayer() else { return nil }

                    let startTime = CFAbsoluteTimeGetCurrent()

                    // NOTE: `AVPlayerItem` will require `Sendable` in order to instantiate in background.
                    let playerItem = AVPlayerItem(asset: asset)
                    let playerItemInitTime = CFAbsoluteTimeGetCurrent() - startTime

                    player.replaceCurrentItem(with: playerItem)
                    let playerItemReplacedTime = CFAbsoluteTimeGetCurrent() - startTime

                    return ._subscribePlayerAfterReload(
                        assetInitTime: assetInitTime,
                        playerItemInitTime: playerItemInitTime,
                        playerItemReplacedTime: playerItemReplacedTime,
                        wasPaused: wasPaused
                    )
                }

        case ._reload(.none):
            state.playerState.playingStatus = .paused

            // Cancellation of subscription using `PlayerSubscriptionEffectQueue`.
            return Effect.fireAndForget(queue: PlayerSubscriptionEffectQueue()) {}

        case let ._subscribePlayerAfterReload(assetInitTime, playerItemInitTime, playerItemReplacedTime, wasPaused):
            state.playerState.assetInitTime = assetInitTime
            state.playerState.playerItemInitTime = playerItemInitTime
            state.playerState.playerItemReplacedTime = playerItemReplacedTime
            state.playerState.duration = .nan

            return (!wasPaused ? Effect.nextAction(.play) : .empty)
                + environment.playerSubscriptionEffect.map { ._playerAction($0) }

        case let ._playerAction(.periodicTime(time)):
            if !state.isSeeking {
                state.playerState.currentTime = time.seconds
            }

        case let ._playerAction(.playingStatus(playingStatus)):
            state.playerState.playingStatus = playingStatus

        case let ._playerAction(.playerRate(playerRate)):
            state.playerState.playerRate = playerRate

        case let ._playerAction(.outputVolume(outputVolume)):
            state.playerState.outputVolume = outputVolume

        case let ._playerAction(.playerItemStatus(playerItemStatus)):
            state.playerState.playerItemStatus = playerItemStatus

        case let ._playerAction(.playerItemError(errorString)):
            state.playerState.errorString = errorString

        case let ._playerAction(.timebaseRate(timebaseRate)):
            state.playerState.timebaseRate = timebaseRate

        case ._playerAction(.timeJumped):
            print("===> timeJumped")

        case let ._playerAction(.loadedTimeRanges(loadedTimeRanges)):
            state.playerState.loadedTimeRanges = loadedTimeRanges

        case let ._playerAction(.seekableTimeRanges(seekableTimeRanges)):
            state.playerState.seekableTimeRanges = seekableTimeRanges

        case ._playerAction(.didPlayEndToTime):
            print("===> didPlayEndToTime")

        case let ._playerAction(.failedToPlayToEndTime(errorString)):
            state.playerState.errorString = errorString

        case let ._playerAction(.isPlaybackLikelyToKeepUp(isPlaybackLikelyToKeepUp)):
            state.playerState.isPlaybackLikelyToKeepUp = isPlaybackLikelyToKeepUp

        case let ._playerAction(.playbackBufferState(playbackBufferState)):
            state.playerState.playbackBufferState = playbackBufferState

        case ._playerAction(.playbackStalled):
            print("===> playbackStalled")

        case let ._playerAction(.timedMetadataGroups(timedMetadataGroups)):
            state.playerState.timedMetadataGroups = timedMetadataGroups

        case let ._playerAction(.newAccessLogEvent(newAccessLogEvent)):
            state.playerState.newAccessLogEvent = prettify(newAccessLogEvent.descriptionDictionary).unescaped

        case let ._playerAction(.newErrorLogEvent(newErrorLogEvent)):
            state.playerState.newErrorLogEvent = prettify(newErrorLogEvent.descriptionDictionary).unescaped

        case let ._playerAction(.isPlayable(isPlayable)):
            state.playerState.isPlayable = isPlayable

        case let ._playerAction(.duration(duration)):
            state.playerState.duration = duration

        case let .updateSliderValue(sliderValue):
            state.sliderValue = sliderValue

        case .didFinishSliderSeeking:
            let wasPaused = state.playerState.playingStatus == .paused

            let seekEffect: Effect<RootAction> = state.seekingTime.map { seekingTime in
                Effect {
                    await environment.seek(to: { _ in seekingTime })

                    return RootAction._didFinishPlayerSeeking(
                        seekingTime: seekingTime,
                        wasPaused: wasPaused
                    )
                }
            } ?? .empty

            return Effect.nextAction(.pause)
                + seekEffect

        case let ._didFinishPlayerSeeking(seekingTime, wasPaused):
            state.seekingTime = nil
            state.playerState.currentTime = seekingTime

            if !wasPaused {
                return Effect.nextAction(.play)
            }
            else {
                return Effect.empty
            }

        case .play:
            if state.playerState.playingStatus == .paused {
                return Effect.fireAndForget { @MainActor in
                    guard let player = environment.getPlayer() else { return }
                    player.play()
                }
            }

        case .pause:
            if state.playerState.playingStatus == .playing {
                return Effect.fireAndForget { @MainActor in
                    guard let player = environment.getPlayer() else { return }
                    player.pause()
                }
            }

        case let .advance(seconds):
            return Effect.fireAndForget {
                await environment.seek(to: { $0 + seconds })
            }

        case let .showDialog(label, value):
            state.dialogText = "[\(label)]\n\n\(value.unescaped)"

        case .closeDialog:
            state.dialogText = nil
        }

        return .empty
    }
}

// MARK: - Priavte

private func prettify(_ any: Any) -> String
{
    let options: JSONSerialization.WritingOptions = [
        .prettyPrinted,
        .sortedKeys,
        .withoutEscapingSlashes
    ]

    guard let jsonData = try? JSONSerialization.data(withJSONObject: any, options: options),
          let string = String(data: jsonData, encoding: .utf8)
    else {
        return "(failed prettify)"
    }

    return string
}
