import SwiftUI
import ActomatonStore
import VectorMath

// MARK: - Example

protocol Example
{
    var exampleTitle: String { get }
    var exampleIcon: Image { get }
    var exampleInitialState: PhysicsRoot.State.Current { get }

    /// Object's absolute position from relatvie position using `previous` object's position.
    var absolutePosition: ((_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)? { get }

    var exampleArrowScale: ArrowScale { get }

    @MainActor
    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy) -> AnyView
}

extension Example
{
    /// Default impl.
    var exampleTitle: String
    {
        let title = String(describing: self)
        if let index = title.range(of: "Example")?.lowerBound { // trim "-Example()"
            return String(title.prefix(upTo: index))
        }
        else {
            return title
        }
    }

    /// Default impl.
    var absolutePosition: ((_ relativePosition: Vector2, _ index: Int, _ previous: Vector2) -> Vector2)?
    {
        nil
    }
}

extension Example
{
    /// Helper method to transform parent `Store` into child `Store`, then `makeView`.
    @MainActor
    static func exampleView<ChildAction, ChildState, V: View>(
        store: Store<PhysicsRoot.Action, PhysicsRoot.State>.Proxy,
        actionPath: CasePath<PhysicsRoot.Action, ChildAction>,
        statePath: CasePath<PhysicsRoot.State.Current, ChildState>,
        makeView: @MainActor (Store<ChildAction, ChildState>.Proxy) -> V
    ) -> AnyView
    {
        @MainActor
        @ViewBuilder
        func _exampleView() -> some View
        {
            if let substore = store.current
                .traverse(\.self)?[casePath: statePath]
                .traverse(\.self)?
                .map(action: actionPath)
            {
                makeView(substore)
            }
        }

        return AnyView(_exampleView())
    }
}

// MARK: - ObjectWorldExample

/// Example using `World` and `WorldView`.
protocol ObjectWorldExample: Example
{
    /// Custom logic called on every "tick" to modify `objects`, mainly to calculate surrounding forces.
    /// - Note: `object`'s `velocity` and `position` will be automatically calculated afterwards.
    func step(objects: inout [Object], boardSize: CGSize)

    /// Custom logic called on "dragging empty space" to modify `objects`.
    func draggingVoid(_ objects: inout [Object], point: CGPoint)
}

extension ObjectWorldExample
{
    /// Default impl.
    func draggingVoid(_ objects: inout [Object], point: CGPoint) {}

    var reducer: Reducer<World.Action, World.State<Object>, World.Environment>
    {
        World.reducer(
            tick: World.tick(self.step),
            tap: { $0.append(Object(position: Vector2($1))) },
            draggingObj: { $0.position = Vector2($1) },
            draggingVoid: self.draggingVoid
        )
    }
}

// MARK: - BobWorldExample

/// Pendulum example using `Bob`s.
protocol BobWorldExample: Example
{
    /// Custom logic called on every "tick" to modify `objects`, mainly to calculate angular acceleration.
    func step(objects: inout [Bob], boardSize: CGSize)

    /// Custom logic called on "dragging empty space" to modify `objects`.
    func draggingVoid(_ objects: inout [Bob], point: CGPoint)
}

extension BobWorldExample
{
    /// Default impl.
    func draggingVoid(_ objects: inout [Bob], point: CGPoint) {}

    var reducer: Reducer<World.Action, World.State<Bob>, World.Environment>
    {
        World.reducer(
            tick: World.tick(self.step),
            tap: { _, _ in },
            draggingObj: { _, _ in },
            draggingVoid: self.draggingVoid
        )
    }
}
