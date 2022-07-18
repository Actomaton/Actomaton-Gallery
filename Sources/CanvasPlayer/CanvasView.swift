import SwiftUI
import ActomatonUI
import CommonUI
import Utilities

/// Canvas view that tracks tap / drag gestures and orientation.
@MainActor
public struct CanvasView<CanvasState>: View
    where CanvasState: Equatable & Sendable
{
    let store: Store<Action, State<CanvasState>, Void>
    let content: @MainActor (Store<Action, State<CanvasState>, Void>) -> AnyView

    @ObservedObject
    private var canvasSize: ViewStore<Action, CGSize>

    /// Initializer with custom `content`.
    public init(
        store: Store<Action, State<CanvasState>, Void>,
        content: @MainActor @escaping (Store<Action, State<CanvasState>, Void>) -> AnyView
    )
    {
        let _ = Debug.print("CanvasPlayer.CanvasView.init")

        self.store = store
        self.content = content
        self.canvasSize = store.indirectMap(state: \.canvasSize).viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("CanvasPlayer.CanvasView.body")

        GeometryReader { geometry in
            self.canvas(geometrySize: geometry.size)
        }
    }

    private func canvas(geometrySize: CGSize) -> some View
    {
        let contentSize = self.canvasSize.state

        return ZStack(alignment: .topLeading) {
            // Content to be drawn, e.g. objects, pendulums.
            content(self.store)

            // NOTE:
            // `TapView` is used to detect touched location which is not possible
            // as of Xcode 11.1 SwiftUI.
            TapView { point in
//                print("===> TapView", point)
                self.store.send(.tap(point))
            }
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
        .border(Color.green, width: 2)
        .onChange(of: geometrySize) { newValue in
            print("===> onChange(of: self.geometrySize) = \(newValue)")
            if self.canvasSize.state != newValue {
                self.store.send(.updateCanvasSize(newValue))
            }
        }
        .onAppear {
            self.store.send(.updateCanvasSize(geometrySize))

            Task {
                try await Task.sleep(nanoseconds: 100_000_000)
                self.store.send(.startTimer)
            }
        }
    }
}
