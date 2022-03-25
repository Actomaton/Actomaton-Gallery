import AVFoundation
import Combine
import SwiftUI
import AVFoundation_Combine

enum RootAction: Sendable
{
    // Reload
    case reloadRandom
    case _reload(URL?)

    case _subscribePlayerAfterReload(
        assetInitTime: CFAbsoluteTime,
        playerItemInitTime: CFAbsoluteTime,
        playerItemReplacedTime: CFAbsoluteTime,
        wasPaused: Bool
    )

    // Player control.
    case play
    case pause
    case advance(seconds: TimeInterval)

    // Slider seek.
    case updateSliderValue(Float)
    case didFinishSliderSeeking
    case _didFinishPlayerSeeking(seekingTime: TimeInterval, wasPaused: Bool)

    // Dialog.
    case showDialog(label: String, value: String)
    case closeDialog

    // Inner Player actions.
    case _playerAction(PlayerAction)
}
