import SwiftUI
import ActomatonUI
import CommonUI
import CanvasPlayer

/// Physics world view based on `CanvasPlayerView`.
@MainActor
struct WorldView<Obj>: View where Obj: ObjectLike & Equatable
{
    let store: Store<World.Action, World.State<Obj>, Void>
    let configuration: WorldConfiguration
    let content: @MainActor (Store<CanvasPlayer.Action, CanvasPlayer.State<World.CanvasState<Obj>>, Void>, WorldConfiguration) -> AnyView

    /// Initializer with custom `content`.
    init<V>(
        store: Store<World.Action, World.State<Obj>, Void>,
        configuration: WorldConfiguration,
        content: @MainActor @escaping (Store<CanvasPlayer.Action, CanvasPlayer.State<World.CanvasState<Obj>>, Void>, WorldConfiguration) -> V
    ) where V: View
    {
        self.store = store
        self.configuration = configuration
        self.content = { AnyView(content($0, $1)) }
    }

    var body: some View
    {
        CanvasPlayerView(
            store: self.store.map(state: \.canvasPlayerState),
            content: { store in
                AnyView(
                    self.content(store, self.configuration)
                )
            }
        )
        .padding()
    }
}
