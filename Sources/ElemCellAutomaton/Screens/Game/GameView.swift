import SwiftUI
import ActomatonUI
import CommonUI

@MainActor
struct GameView: View
{
    private let store: Store<Game.Action, Game.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Game.Action, Game.State>

    init(
        store: Store<Game.Action, Game.State, Void>
    )
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    var body: some View
    {
        cellsPath()
            .foregroundColor(Color.green)
            .drawingGroup()
    }

    private func cell(point: Board.Point, cellLength: CGFloat) -> some View
    {
        return Rectangle()
            .fill(Color.green)
            .frame(
                width: cellLength,
                height: cellLength
            )
            .position(
                x: (CGFloat(point.x) + 0.5) * cellLength,
                y: (CGFloat(point.y) + 0.5) * cellLength
            )
    }

    private func cellsPath() -> Path
    {
        let cellLength = self.viewStore.cellLength
        let liveCellPoints = self.viewStore.board.liveCellPoints

        var path = Path()

        for point in liveCellPoints {
            let rect = CGRect(x: cellLength * CGFloat(point.x), y: cellLength * CGFloat(point.y), width: cellLength, height: cellLength)
            path.addRect(rect)
        }

        return path
    }
}

// MARK: - Preview

struct ElemCellAutomaton_GameView_Previews: PreviewProvider
{
    @ViewBuilder
    static func makePreviews(environment: Game.Environment, isMultipleScreens: Bool) -> some View
    {
        let gameView = GameView(
            store: Store(
                state: .init(pattern: .init(rule: 110), cellLength: 5, timerInterval: 0.05),
                reducer: Game.reducer(),
                environment: environment
            )
            .noEnvironment
        )

        gameView
            .previewDisplayName("Portrait")
//            .previewInterfaceOrientation(.portrait)

        if isMultipleScreens {
//            gameView
//                .previewDisplayName("Landscape")
//                .previewInterfaceOrientation(.landscapeRight)
        }
    }

    /// - Note: Uses mock environment.
    static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                timer: { _ in AsyncStream(unfolding: { nil }) }
            ),
            isMultipleScreens: true
        )
    }
}
