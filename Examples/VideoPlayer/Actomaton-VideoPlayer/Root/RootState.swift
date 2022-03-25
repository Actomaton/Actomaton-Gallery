import AVFoundation
import Combine
import SwiftUI
import AVFoundation_Combine

struct RootState: Equatable, Sendable
{
    var playerState: PlayerState = .init()
    var dialogText: String?
    var seekingTime: TimeInterval?

    var sliderValue: Float
    {
        get { Float((seekingTime ?? playerState.currentTime) / playerState.duration) }
        set {
            seekingTime = TimeInterval(newValue) * playerState.duration
        }
    }

    var isSeeking: Bool
    {
        seekingTime != nil
    }

    var isSliderEnabled: Bool
    {
        playerState.playerItemStatus == .readyToPlay
    }

    var mirroredChildren: [(label: String, value: String)]
    {
        playerState.mirroredChildren
    }
}
