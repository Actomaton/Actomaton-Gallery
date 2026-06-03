import SwiftUI
import ElemCellAutomaton
import ActomatonUI
import CanvasPlayerUI
import CellGridView
import Utilities

@MainActor
public struct ElemCellAutomatonView: View
{
    private let store: Store<Action, State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Action, State>

    public init(store: Store<Action, State, Void>)
    {
        let _ = Debug.print("ElemCellAutomatonView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("ElemCellAutomatonView.body")

        CanvasPlayerView(
            store: self.store
                .map(state: \.game.canvasPlayerState)
                .contramap(action: Action.game)
                .contramap(action: ElemCellAutomaton.Action.canvasPlayer),
            content: { store in
                AnyView(
                    CellGridView(
                        store: self.store
                            .map(state: \.game)
                            .contramap(action: (/Action.game).embed),
                        cellLength: { CGFloat($0.cellLength) },
                        liveCells: { state in state.board.liveCellPoints.map { GridPoint(x: $0.x, y: $0.y) } }
                    )
                )
            },
            bottomView: { _ in
                AnyView(
                    RuleInputView(
                        value: viewStore.binding(
                            get: { $0.game.selectedPattern.rule },
                            onChange: { newValue in
                                .game(.setRule(newValue))
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

public struct ElemCellAutomatonView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Environment, isMultipleScreens: Bool) -> some View
    {
        let elemCellAutomatonView = ElemCellAutomatonView(
            store: Store<Action, State, Environment>(
                state: .init(pattern: .init(rule: 110), cellLength: 5, timerInterval: 0.05),
                reducer: reducer(),
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
