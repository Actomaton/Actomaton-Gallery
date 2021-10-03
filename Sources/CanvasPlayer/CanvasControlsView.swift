import SwiftUI
import ActomatonStore

/// Play/pause, tick, rewind buttons.
@MainActor
public struct CanvasControlsView: View
{
    let isRunningTimer: Bool
    let send: (Action) -> Void

    public init(isRunningTimer: Bool, send: @escaping (Action) -> Void)
    {
        self.isRunningTimer = isRunningTimer
        self.send = send
    }

    public var body: some View
    {
        HStack {
            Spacer()

            Button(action: { self.send(.resetCanvas) }) {
                Image(systemName: "arrow.uturn.left.circle")
            }

            Spacer()

            if isRunningTimer {
                Button(action: { self.send(.stopTimer) }) {
                    Image(systemName: "pause.circle")
                }
            }
            else {
                Button(action: { self.send(.startTimer) }) {
                    Image(systemName: "play.circle")
                }
            }

            Spacer()

            Button(action: { self.send(.tick) }) {
                Image(systemName: "chevron.right.circle")
            }

            Spacer()
        }
        .font(.largeTitle)
    }
}
