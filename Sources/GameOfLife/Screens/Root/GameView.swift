import SwiftUI
import ActomatonStore
import CommonUI

@MainActor
struct GameView: View
{
    private let store: Store<Game.Action, Game.State>.Proxy

    init(
        store: Store<Game.Action, Game.State>.Proxy
    )
    {
        self.store = store
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
        let cellLength = self.store.state.cellLength
        let liveCellPoints = self.store.state.board.liveCellPoints

        var path = Path()

        for point in liveCellPoints {
            let rect = CGRect(x: cellLength * CGFloat(point.x), y: cellLength * CGFloat(point.y), width: cellLength, height: cellLength)
            path.addRect(rect)
        }

        return path
    }
}

// MARK: - Preview

struct GameView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let gameView = GameView(
            store: .init(
                state: .constant(.init(pattern: .glider, cellLength: 5, timerInterval: 1)),
                send: { _ in }
            )
        )

        return Group {
            gameView.previewLayout(.sizeThatFits)
                .previewDisplayName("Portrait")

            gameView.previewLayout(.fixed(width: 568, height: 320))
                .previewDisplayName("Landscape")
        }
    }
}
