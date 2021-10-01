import SwiftUI
import ActomatonStore
import CommonUI
import CanvasPlayer

/// Physics world view based on `CanvasPlayerView`.
@MainActor
struct WorldView<Obj>: View where Obj: ObjectLike & Equatable
{
    let store: Store<World.Action, World.State<Obj>>.Proxy
    let configuration: WorldConfiguration
    let content: @MainActor (Store<CanvasPlayer.Action, CanvasPlayer.State<World.CanvasState<Obj>>>.Proxy, WorldConfiguration) -> AnyView

    /// Initializer with custom `content`.
    init(
        store: Store<World.Action, World.State<Obj>>.Proxy,
        configuration: WorldConfiguration,
        content: @MainActor @escaping (Store<CanvasPlayer.Action, CanvasPlayer.State<World.CanvasState<Obj>>>.Proxy, WorldConfiguration) -> AnyView
    )
    {
        self.store = store
        self.configuration = configuration
        self.content = content
    }

    var body: some View
    {
        CanvasPlayerView(store: self.store.canvasPlayerState, content: { store in
            self.content(store, self.configuration)
        })
            .padding()
    }
}
