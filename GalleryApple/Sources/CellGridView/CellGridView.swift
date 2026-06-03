import SwiftUI
import ActomatonUI

/// A read-only live-cell grid renderer shared by the canvas-based board games
/// (GameOfLife, ElemCellAutomaton): draws each live cell as a `cellLength`-sized square into a
/// single `Path`. Generic over the concrete `Action` / `State`; the caller supplies how to read
/// the cell size and the live cells from the state.
@MainActor
public struct CellGridView<Action: Sendable, State: Equatable & Sendable>: View
{
    @ObservedObject
    private var viewStore: ViewStore<Action, State>

    private let cellColor: Color
    private let cellLength: (State) -> CGFloat
    private let liveCells: (State) -> [GridPoint]

    public init(
        store: Store<Action, State, Void>,
        cellColor: Color = .green,
        cellLength: @escaping (State) -> CGFloat,
        liveCells: @escaping (State) -> [GridPoint]
    )
    {
        self.viewStore = store.viewStore
        self.cellColor = cellColor
        self.cellLength = cellLength
        self.liveCells = liveCells
    }

    public var body: some View
    {
        cellsPath()
            .foregroundColor(cellColor)
            .drawingGroup()
    }

    private func cellsPath() -> Path
    {
        let state = self.viewStore.state
        let cellLength = self.cellLength(state)

        var path = Path()
        for point in self.liveCells(state) {
            path.addRect(
                CGRect(
                    x: cellLength * CGFloat(point.x),
                    y: cellLength * CGFloat(point.y),
                    width: cellLength,
                    height: cellLength
                )
            )
        }
        return path
    }
}

/// Integer grid coordinate of a live cell (see `CellGridView`).
public struct GridPoint: Equatable, Sendable
{
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int)
    {
        self.x = x
        self.y = y
    }
}
