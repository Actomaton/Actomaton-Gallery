import SwiftUI
import ActomatonStore
import CommonUI

/// Physics world view that attaches UI controls, tap / drag gestures, orientation detection, etc.
@MainActor
struct WorldView<Obj>: View where Obj: ObjectLike & Equatable
{
    let store: Store<World.Action, World.State<Obj>>.Proxy
    let configuration: WorldConfiguration
    let content: @MainActor (Store<World.Action, World.State<Obj>>.Proxy, WorldConfiguration) -> AnyView

    /// Initializer with custom `content`.
    init(
        store: Store<World.Action, World.State<Obj>>.Proxy,
        configuration: WorldConfiguration,
        content: @MainActor @escaping (Store<World.Action, World.State<Obj>>.Proxy, WorldConfiguration) -> AnyView
    )
    {
        self.store = store
        self.configuration = configuration
        self.content = content
    }

    var body: some View
    {
        VStack {
            GeometryReader { geometry in
                board(geometrySize: geometry.size)
            }

            controlButtons()
        }
        .padding()
    }

    private func board(geometrySize: CGSize) -> some View
    {
        let contentSize = self.store.state.boardSize

        return ZStack(alignment: .topLeading) {
            // Content to be drawn, e.g. objects, pendulums.
            content(self.store, self.configuration)

            // NOTE:
            // `TapView` is used to detect touched location which is not possible
            // as of Xcode 11.1 SwiftUI.
            TapView { point in
//                print("===> TapView", point)
                self.store.send(.tap(point))
            }
            .border(Color.green, width: 2)
            .gesture(
                DragGesture()
                    .onChanged { value in
//                        print("===> onChanged", value.location)
                        self.store.send(.dragging(value.location))
                    }
                    .onEnded { value in
//                        print("===> onEnded", value.location)
                        self.store.send(.dragEnd)
                    }
            )
        }
        .frame(
            width: contentSize.width,
            height: contentSize.height
        )
        .clipped()
        .border(Color.green, width: 4)
        .onChange(of: geometrySize) { newValue in
            print("===> onChange(of: self.geometrySize) = \(newValue)")
            if self.store.state.boardSize != newValue {
                self.store.send(.updateBoardSize(newValue))
            }
        }
        .onAppear {
            self.store.send(.updateBoardSize(geometrySize))
            self.store.send(.startTimer)
        }
    }

    private func controlButtons() -> some View
    {
        HStack {
            Spacer()

            Button(action: { self.store.send(.resetBoard) }) {
                Image(systemName: "arrow.uturn.left.circle")
            }

            Spacer()

            if self.store.state.isRunningTimer {
                Button(action: { self.store.send(.stopTimer) }) {
                    Image(systemName: "pause.circle")
                }
            }
            else {
                Button(action: { self.store.send(.startTimer) }) {
                    Image(systemName: "play.circle")
                }
            }

            Spacer()

            Button(action: { self.store.send(.tick) }) {
                Image(systemName: "chevron.right.circle")
            }

            Spacer()
        }
        .font(.largeTitle)
    }
}
