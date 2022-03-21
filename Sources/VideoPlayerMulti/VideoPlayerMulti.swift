import UIKit
import Combine
import AVFoundation
import Actomaton
import ActomatonDebugging
import VideoPlayer

// MARK: - Action

public enum Action: Sendable
{
    case videoPlayer1(VideoPlayer.Action)
    case videoPlayer2(VideoPlayer.Action)
}

// MARK: - State

public struct State: Equatable, Sendable
{
    var displayMode: DisplayMode

    var videoPlayer1: VideoPlayer.State = .init(label: "videoPlayer1")
    var videoPlayer2: VideoPlayer.State = .init(label: "videoPlayer2")

    public init(displayMode: DisplayMode)
    {
        self.displayMode = displayMode
    }

    public enum DisplayMode: String, Equatable, Sendable
    {
        case singleSyncedPlayer
        case multiplePlayers
    }
}

// MARK: - Environment

public struct Environment: Sendable
{
    let description: String
    let videoPlayer1: VideoPlayer.Environment
    let videoPlayer2: VideoPlayer.Environment

    public init(
        description: String,
        videoPlayer1: VideoPlayer.Environment,
        videoPlayer2: VideoPlayer.Environment
    )
    {
        self.description = description
        self.videoPlayer1 = videoPlayer1
        self.videoPlayer2 = videoPlayer2
    }
}

// MARK: - Reducer

public var reducer: Reducer<Action, State, Environment>
{
    return .init { action, state, environment in
        _reducer(mode: state.displayMode)
            .run(action, &state, environment)
    }
}

private func _reducer(mode: State.DisplayMode) -> Reducer<Action, State, Environment>
{
    Reducer.combine(
        VideoPlayer.reducer
            .contramap(action: /Action.videoPlayer1)
            .contramap(state: \.videoPlayer1)
            .contramap(environment: \.videoPlayer1),

        VideoPlayer.reducer
            .contramap(action: /Action.videoPlayer2)
            .contramap(state: \.videoPlayer2)
            .contramap(environment: {
                // Environment switching.
                switch mode {
                case .singleSyncedPlayer:
                    return \.videoPlayer1 // Use same environment as `videoPlayer1`.
                case .multiplePlayers:
                    return \.videoPlayer2
                }
            }())
    )
}
