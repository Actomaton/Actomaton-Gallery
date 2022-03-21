import SwiftUI
import ActomatonStore
import CommonUI

/// Canvas + timer player view that attaches `content`, `bottomView`, UI controls, tap / drag gestures, orientation detection.
@MainActor
public struct CanvasPlayerView<CanvasState>: View
    where CanvasState: Equatable & Sendable
{
    let store: Store<Action, State<CanvasState>, Void>.Proxy
    let content: @MainActor (Store<Action, State<CanvasState>, Void>.Proxy) -> AnyView
    let bottomView: @MainActor (Store<Action, State<CanvasState>, Void>.Proxy) -> AnyView

    /// Initializer with custom `content`.
    public init(
        store: Store<Action, State<CanvasState>, Void>.Proxy,
        content: @MainActor @escaping (Store<Action, State<CanvasState>, Void>.Proxy) -> AnyView,
        bottomView: @MainActor @escaping (Store<Action, State<CanvasState>, Void>.Proxy) -> AnyView = { _ in AnyView(EmptyView()) }
    )
    {
        self.store = store
        self.content = content
        self.bottomView = bottomView
    }

    public var body: some View
    {
        VStack {
            CanvasView(store: self.store, content: self.content)

            self.bottomView(self.store)

            CanvasControlsView(
                isRunningTimer: self.store.state.isRunningTimer,
                send: { self.store.send($0) }
            )
        }
    }
}
