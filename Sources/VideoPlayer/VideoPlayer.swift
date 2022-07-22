import UIKit
import Combine
import AVFoundation
import AVFoundation_Combine
import Actomaton
import ActomatonDebugging
import Utilities

// MARK: - Action

public enum Action: Sendable
{
    case subscribePlayer
    case start
    case stop
    case backward(seconds: TimeInterval)
    case forward(seconds: TimeInterval)
    case seek(to: TimeInterval)

    case _updatePlayingStatus(PlayingStatus)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    let label: String

    var playingStatus: PlayingStatus = .unknown

    public init(label: String)
    {
        self.label = label
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    public let getPlayer: @MainActor @Sendable () -> AVPlayer?
    public let setPlayer: @MainActor @Sendable (AVPlayer?) -> Void

    public init(
        getPlayer: @escaping @MainActor @Sendable () -> AVPlayer?,
        setPlayer: @escaping @MainActor @Sendable (AVPlayer?) -> Void
    )
    {
        self.getPlayer = getPlayer
        self.setPlayer = setPlayer
    }
}

// MARK: - EffectQueue

/// Player observation queue per each `label`, with old subscription auto-cancellation.
public struct PlayerSubscriptionQueue: Newest1EffectQueueProtocol
{
    /// Label used to identify a video player in case of multiple players being presented at same time,
    /// but each player's subscription (effect) should not interfere with each other.
    let label: String
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    .debug(name: "===> VideoPlayer") { action, state, environment in
        switch action {
        case .subscribePlayer:
            return Effect(
                queue: PlayerSubscriptionQueue(label: state.label),
                sequence: { @MainActor () -> AsyncStream<Action> in
                    guard let player = environment.getPlayer() else {
                        return AsyncStream(unfolding: { nil })
                    }

                    return player.playingStatusPublisher
                        .map(Action._updatePlayingStatus)
                        .toAsyncStream()
                }
            )

        case .start:
            return Effect.fireAndForget { @MainActor in
                guard let player = environment.getPlayer() else { return }
                player.play()
            }

        case .stop:
            return Effect.fireAndForget { @MainActor in
                guard let player = environment.getPlayer() else { return }
                player.pause()
            }

        case let .backward(seconds):
            return Effect.fireAndForget { @MainActor in
                guard let player = environment.getPlayer() else { return }

                let currentTime = player.currentTime()

                player.seek(to: currentTime - CMTime(seconds: seconds, preferredTimescale: 1)) { success in
                    print("seek backward", success)
                }
            }

        case let .forward(seconds):
            return Effect.fireAndForget { @MainActor in
                guard let player = environment.getPlayer() else { return }

                let currentTime = player.currentTime()

                player.seek(to: currentTime + CMTime(seconds: seconds, preferredTimescale: 1)) { success in
                    print("seek forward", success)
                }
            }

        case let .seek(to: seconds):
            return Effect.fireAndForget { @MainActor in
                guard let player = environment.getPlayer() else { return }

                player.seek(to: CMTime(seconds: seconds, preferredTimescale: 1)) { success in
                    print("seek to", success)
                }
            }

        case let ._updatePlayingStatus(playingStatus):
            state.playingStatus = playingStatus
            return .empty
        }
    }
}
