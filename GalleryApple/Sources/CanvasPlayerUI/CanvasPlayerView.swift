import SwiftUI
import ActomatonUI
import CommonUI
import Utilities

/// Canvas + timer player view that attaches `content`, `bottomView`, UI controls, tap / drag gestures, orientation detection.
@MainActor
public struct CanvasPlayerView<CanvasState>: View
    where CanvasState: Equatable & Sendable
{
    let store: Store<Action, State<CanvasState>, Void>
    let content: @MainActor (Store<Action, State<CanvasState>, Void>) -> AnyView
    let bottomView: @MainActor (Store<Action, State<CanvasState>, Void>) -> AnyView

    /// Initializer with custom `content`.
    public init(
        store: Store<Action, State<CanvasState>, Void>,
        content: @MainActor @escaping (Store<Action, State<CanvasState>, Void>) -> AnyView,
        bottomView: @MainActor @escaping (Store<Action, State<CanvasState>, Void>) -> AnyView = { _ in AnyView(EmptyView()) }
    )
    {
        let _ = Debug.print("CanvasPlayer.CanvasPlayerView.init")

        self.store = store
        self.content = content
        self.bottomView = bottomView
    }

    public var body: some View
    {
        let _ = Debug.print("CanvasPlayer.CanvasPlayerView.body")

        VStack {
            CanvasView(store: self.store, content: self.content)

            self.bottomView(self.store)

            WithViewStore(store.indirectMap(state: \.isRunningTimer)) { viewStore in
                CanvasControlsView(
                    isRunningTimer: viewStore.state,
                    send: { self.store.send($0) }
                )
            }
        }
    }
}
