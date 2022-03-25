import AVFoundation
import Combine
import SwiftUI
import Actomaton

struct RootEnvironment: Sendable
{
    let getPlayer: @MainActor @Sendable () -> AVPlayer?
    let getRandomVideoURL: @Sendable () -> URL?
}

extension RootEnvironment
{
    var playerSubscriptionEffect: Effect<PlayerAction>
    {
        Effect(
            queue: PlayerSubscriptionEffectQueue(),
            sequence: { @MainActor () -> AsyncStream<PlayerAction> in
                guard let player = self.getPlayer() else {
                    return AsyncStream(unfolding: { nil })
                }

                let playerPublishers: [AnyPublisher<PlayerAction, Never>] = [
                    player.periodicTimePublisher(interval: CMTime(seconds: 0.1, preferredTimescale: 100))
                        .map { .periodicTime($0) }
                        .eraseToAnyPublisher(),

                    player
                        .boundaryTimePublisher(
                            times: (1 ... 3).map { CMTime(seconds: Double($0), preferredTimescale: 100) }
                        )
                        .print("boundaryTime")
                        .flatMap { Combine.Empty<PlayerAction, Never>(completeImmediately: true) }
                        .eraseToAnyPublisher(),

                    player.playingStatusPublisher
                        .map { .playingStatus($0) }
                        .eraseToAnyPublisher(),

                    player.ratePublisher
                        .map { .playerRate($0) }
                        .eraseToAnyPublisher()
                ]

                let playerItemPublishers: [AnyPublisher<PlayerAction, Never>] = {
                    guard let currentItem = player.currentItem else { return [] }

                    return [
                        currentItem.statusPublisher
                            .map { .playerItemStatus($0) }
                            .eraseToAnyPublisher(),

                        currentItem.errorPublisher
                            .map { .playerItemError(String(describing: $0)) }
                            .eraseToAnyPublisher(),

                        currentItem.timebaseRatePublisher
                            .receive(on: DispatchQueue.main) // Required for @MainActor data-race detection.
                            .map { .timebaseRate($0) }
                            .eraseToAnyPublisher(),

                        currentItem.timeJumpedPublisher
                            .map { _ in .timeJumped }
                            .eraseToAnyPublisher(),

                        currentItem.playbackStalledPublisher
                            .map { _ in .playbackStalled }
                            .eraseToAnyPublisher(),

                        currentItem.loadedTimeRangesPublisher
                            .map { .loadedTimeRanges($0) }
                            .eraseToAnyPublisher(),

                        currentItem.seekableTimeRangesPublisher
                            .map { .seekableTimeRanges($0) }
                            .eraseToAnyPublisher(),

                        currentItem.didPlayEndToTimePublisher
                            .map { _ in .didPlayEndToTime }
                            .eraseToAnyPublisher(),

                        currentItem.failedToPlayToEndTimePublisher
                            .map { .failedToPlayToEndTime(String(describing: $0)) }
                            .eraseToAnyPublisher(),

                        currentItem.isPlaybackLikelyToKeepUpPublisher
                            .map { .isPlaybackLikelyToKeepUp($0) }
                            .eraseToAnyPublisher(),

                        currentItem.playbackBufferStatePublisher
                            .map { .playbackBufferState($0) }
                            .eraseToAnyPublisher(),

                        currentItem.playbackStalledPublisher
                            .map { _ in .playbackStalled }
                            .eraseToAnyPublisher(),

                        currentItem.timedMetadataGroupsPublisher
                            .map { .timedMetadataGroups($0) }
                            .eraseToAnyPublisher(),

                        currentItem.newAccessLogEntryPublisher
                            .flatMap { Publishers.Sequence(sequence: $0.events) }
                            .map { .newAccessLogEvent($0) }
                            .eraseToAnyPublisher(),

                        currentItem.newErrorLogEntryPublisher
                            .flatMap { Publishers.Sequence(sequence: $0.events) }
                            .map { .newErrorLogEvent($0) }
                            .eraseToAnyPublisher()
                    ]
                }()

                let assetPublishers: [AnyPublisher<PlayerAction, Never>] = {
                    guard let asset = player.currentItem?.asset else { return [] }

                    return [
                        asset.isPlayablePublisher
                            .receive(on: DispatchQueue.main) // Required for @MainActor data-race detection.
                            .map { .isPlayable($0) }
                            .catch { _ in Empty(completeImmediately: true) }
                            .eraseToAnyPublisher(),

                        asset.durationPublisher
                            .receive(on: DispatchQueue.main) // Required for @MainActor data-race detection.
                            .map { .duration($0.seconds) }
                            .catch { _ in Empty(completeImmediately: true) }
                            .eraseToAnyPublisher()
                    ]
                }()

                return Combine.Publishers
                    .MergeMany(playerPublishers + playerItemPublishers + assetPublishers + {
#if os(iOS)
                        [
                            AVAudioSession.sharedInstance().outputVolumePublisher
                                .map { .outputVolume($0) }
                                .eraseToAnyPublisher()
                        ]
#else
                        []
#endif
                    }())
                    .toAsyncStream()
            }
        )
    }

    @MainActor
    func seek(to seekTime: @Sendable (_ current: TimeInterval) -> TimeInterval) async
    {
        guard let player = self.getPlayer(),
              let currentItem = player.currentItem else { return }

        let asset = currentItem.asset
        let currentTime = player.currentTime().seconds

        let seekTime = CMTime(seconds: seekTime(currentTime), preferredTimescale: asset.duration.timescale)

        await withCheckedContinuation { continuation in
            player.seek(to: seekTime) { _ in
                continuation.resume()
            }
        }
    }
}

// MARK: - EffectQueue

struct PlayerSubscriptionEffectQueue: Newest1EffectQueueProtocol {}
