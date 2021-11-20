import SwiftUI
import Actomaton
import ActomatonStore

@MainActor
public struct DebugRootView<RootView>: View
    where RootView: View & RootViewProtocol
{
    private let store: Store<DebugAction, DebugState>.Proxy

    public init(store: Store<DebugAction, DebugState>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            RootView(
                store: self.store.timeTravel.inner
                    .contramap(action: { DebugAction.timeTravel(.inner($0)) })
            )
                .frame(maxHeight: .infinity)



            if self.store.state.usesTimeTravel {
                self.timeTravelDebugView()
            }
        }
    }

    @ViewBuilder
    private func timeTravelDebugView() -> some View
    {
        Divider()

        VStack(alignment: .leading) {
            timeTravelHeader()

            HStack {
                timeTravelSlider()
                timeTravelStepper()
            }
        }
        .padding()
    }

    private func timeTravelHeader() -> some View
    {
        HStack {
            Text("⏱ TIME TRAVEL ⌛").bold()
            Spacer()
            Button("Reset", action: { self.store.send(.timeTravel(.resetHistories)) })
        }
    }

    private func timeTravelSlider() -> some View
    {
        HStack {
            Slider(
                value: self.store.timeTravel.timeTravellingSliderValue
                    .stateBinding(onChange: {
                        DebugAction.timeTravel(.timeTravelSlider(sliderValue: $0))
                    }),
                in: self.store.state.timeTravel.timeTravellingSliderRange,
                step: 1
            )
                .disabled(!self.store.state.timeTravel.canTimeTravel)

            Text("\(self.store.state.timeTravel.timeTravellingIndex) / \(Int(self.store.state.timeTravel.timeTravellingSliderRange.upperBound))")
                .font(Font.body.monospacedDigit())
                .frame(minWidth: 80, alignment: .center)
        }
    }

    private func timeTravelStepper() -> some View
    {
        Stepper(
            onIncrement: { self.store.send(.timeTravel(.timeTravelStepper(diff: 1))) },
            onDecrement: { self.store.send(.timeTravel(.timeTravelStepper(diff: -1))) }
        ) {
            EmptyView()
        }
        .frame(width: 100)
    }

    public typealias DebugAction = Action<RootView.Action>
    public typealias DebugState = State<RootView.State>
}

struct DebugRootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        enum RootAction {}

        struct RootState: RootStateProtocol, Equatable {}

        struct RootView: View, RootViewProtocol
        {
            init(store: Store<RootAction, RootState>.Proxy) {}

            var body: some View
            {
                Text("hello")
            }
        }

        return Group {
            DebugRootView<RootView>(
                store: .init(
                    state: .constant(.init(inner: RootState())),
                    send: { _ in }
                )
            )
                .previewLayout(.fixed(width: 320, height: 480))
                .previewDisplayName("Root")
        }
    }
}
