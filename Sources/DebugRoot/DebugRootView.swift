import SwiftUI
import Actomaton
import ActomatonUI
import Utilities
import TimeTravel

@MainActor
public struct DebugRootView<RootView>: View
    where RootView: View & RootViewProtocol
{
    private let store: Store<DebugAction, DebugState, RootView.Environment>

    public init(store: Store<DebugAction, DebugState, RootView.Environment>)
    {
        let _ = Debug.print("DebugRootView.init")

        self.store = store
    }

    public var body: some View
    {
        let _ = Debug.print("DebugRootView.body")

        VStack {
            RootView(
                store: self.store
                    .map(state: \.timeTravel.inner)
                    .contramap(action: { DebugAction.timeTravel(.inner($0)) })
            )
            .frame(maxHeight: .infinity)

            // IMPORTANT:
            // `State.timeTravel.inner` needs to be observed
            // rather than `State.timeTravel.inner.usesTimeTravel` only.
            // Otherwise, `timeTravelStepper` gets disabled after several time-travelling for some reason.
            WithViewStore(store.map(state: \.timeTravel.inner)) { viewStore in
                if viewStore.usesTimeTravel {
                    self.timeTravelDebugView()
                }
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
        WithViewStore(store.indirectMap(state: \.timeTravel.common)) { viewStore in
            HStack {
                Slider(
                    value: viewStore
                        .binding(
                            get: \.timeTravellingSliderValue,
                            onChange: {
                                DebugAction.timeTravel(.timeTravelSlider(sliderValue: $0))
                            }
                        ),
                    in: viewStore.timeTravellingSliderRange,
                    step: 1
                )
                .disabled(!viewStore.canTimeTravel)

                Text("\(viewStore.timeTravellingIndex) / \(Int(viewStore.timeTravellingSliderRange.upperBound))")
                    .font(Font.body.monospacedDigit())
                    .frame(minWidth: 80, alignment: .center)
            }
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

public struct DebugRootView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        enum RootAction {}

        struct RootState: RootStateProtocol, Equatable
        {
            var usesTimeTravel: Bool { true }
        }

        struct RootView: View, RootViewProtocol
        {
            init(store: Store<RootAction, RootState, Void>) {}

            var body: some View
            {
                Text("hello")
            }
        }

        return DebugRootView<RootView>(
            store: .init(
                state: .init(inner: RootState()),
                reducer: DebugRoot.reducer(inner: .empty)
            )
        )
    }
}
