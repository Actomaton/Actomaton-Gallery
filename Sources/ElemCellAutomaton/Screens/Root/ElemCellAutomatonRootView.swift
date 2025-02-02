import SwiftUI
import ActomatonUI
import CanvasPlayer
import Utilities

@MainActor
public struct RootView: View
{
    private let store: Store<ElemCellAutomatonRoot.Action, ElemCellAutomatonRoot.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<ElemCellAutomatonRoot.Action, ElemCellAutomatonRoot.State>

    public init(store: Store<ElemCellAutomatonRoot.Action, ElemCellAutomatonRoot.State, Void>)
    {
        let _ = Debug.print("ElemCellAutomaton.RootView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("ElemCellAutomaton.RootView.body")

        CanvasPlayerView(
            store: self.store
                .map(state: \.game.canvasPlayerState)
                .contramap(action: ElemCellAutomatonRoot.Action.game)
                .contramap(action: Game.Action.canvasPlayer),
            content: { store in
                AnyView(
                    GameView(
                        store: self.store
                            .map(state: \.game)
                            .contramap(action: (/ElemCellAutomatonRoot.Action.game).embed)
                    )
                )
            },
            bottomView: { _ in
                AnyView(
                    RuleInputView(
                        value: viewStore.binding(
                            get: { $0.game.selectedPattern.rule },
                            onChange: { newValue in
                                .game(.updatePattern(Pattern(rule: newValue)))
                            }
                        )
                    )
                    .frame(alignment: .center)
                )
            }
        )
        .padding()
    }
}

// MARK: - Preview

public struct ElemCellAutomaton_RootView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: ElemCellAutomatonRoot.Environment, isMultipleScreens: Bool) -> some View
    {
        let elemCellAutomatonView = RootView(
            store: Store<ElemCellAutomatonRoot.Action, ElemCellAutomatonRoot.State, ElemCellAutomatonRoot.Environment>(
                state: .init(pattern: .init(rule: 110), cellLength: 5, timerInterval: 0.05),
                reducer: ElemCellAutomatonRoot.reducer(),
                environment: environment
            )
            .noEnvironment
        )

        elemCellAutomatonView
            .previewDisplayName("Portrait")
//            .previewInterfaceOrientation(.portrait)

//        elemCellAutomatonView
//            .previewDisplayName("Landscape")
//            .previewInterfaceOrientation(.landscapeRight)
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                timer: { _ in AsyncStream(unfolding: { nil }) }
            ),
            isMultipleScreens: true
        )
    }
}
