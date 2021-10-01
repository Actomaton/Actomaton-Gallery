import SwiftUI
import ActomatonStore
import CommonUI

/// Canvas view that tracks tap / drag gestures and orientation.
@MainActor
public struct CanvasView<CanvasState>: View where CanvasState: Equatable
{
    let store: Store<Action, State<CanvasState>>.Proxy
    let content: @MainActor (Store<Action, State<CanvasState>>.Proxy) -> AnyView

    /// Initializer with custom `content`.
    public init(
        store: Store<Action, State<CanvasState>>.Proxy,
        content: @MainActor @escaping (Store<Action, State<CanvasState>>.Proxy) -> AnyView
    )
    {
        self.store = store
        self.content = content
    }

    public var body: some View
    {
        GeometryReader { geometry in
            self.canvas(geometrySize: geometry.size)
        }
    }

    private func canvas(geometrySize: CGSize) -> some View
    {
        let contentSize = self.store.state.canvasSize

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
            if self.store.state.canvasSize != newValue {
                self.store.send(.updateCanvasSize(newValue))
            }
        }
        .onAppear {
            self.store.send(.updateCanvasSize(geometrySize))

            Task {
                await Task.sleep(100_000_000)
                self.store.send(.startTimer)
            }
        }
    }
}
