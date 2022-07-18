import SwiftUI
import ActomatonUI
import VectorMath
import CanvasPlayer

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
    func exampleView(store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>) -> AnyView
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
        store: Store<PhysicsRoot.Action, PhysicsRoot.State, Void>,
        action: @escaping (ChildAction) -> PhysicsRoot.Action,
        statePath: CasePath<PhysicsRoot.State.Current, ChildState>,
        makeView: @MainActor (Store<ChildAction, ChildState, Void>) -> V
    ) -> AnyView
    {
        @MainActor
        @ViewBuilder
        func _exampleView() -> some View
        {
            if let substore = store
                .map(state: \.current)
                .optionalize()?
                .caseMap(state: statePath)
                .optionalize()?
                .contramap(action: action)
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
    associatedtype Obj: _ObjectLike

    /// Custom logic called on every "tick" to modify `objects`, mainly to calculate surrounding forces.
    /// - Note: `object`'s `velocity` and `position` will be automatically calculated afterwards.
    func step(objects: inout [Obj], boardSize: CGSize)

    /// Custom logic called on "dragging empty area" to modify `objects`.
    func draggingEmptyArea(_ objects: inout [Obj], point: CGPoint)

    /// Custom logic called on "drag-end empty area" to modify `objects`.
    func dragEndEmptyArea(_ objects: inout [Obj])

    /// Creating a new object on tap.
    func exampleTapToMakeObject(point: CGPoint) -> Obj?
}

extension ObjectWorldExample where Obj == CircleObject
{
    /// Default impl.
    func draggingEmptyArea(_ objects: inout [Obj], point: CGPoint) {}

    /// Default impl.
    func dragEndEmptyArea(_ objects: inout [Obj]) {}

    /// Default impl.
    func exampleTapToMakeObject(point: CGPoint) -> Obj?
    {
        CircleObject(position: Vector2(point))
    }

    var reducer: Reducer<World.Action, World.State<Obj>, World.Environment>
    {
        World
            .reducer(
                tick: World.tickForObjects(self.step),
                tap: { objects, point in
                    if let object = exampleTapToMakeObject(point: point) {
                        objects.append(object)
                    }
                },
                draggingObj: { $0.position = Vector2($1) },
                draggingEmptyArea: self.draggingEmptyArea,
                dragEndEmptyArea: self.dragEndEmptyArea
            )
    }
}

extension ObjectWorldExample where Obj == Object
{
    /// Default impl.
    func draggingEmptyArea(_ objects: inout [Obj], point: CGPoint) {}

    /// Default impl.
    func exampleTapToMakeObject(point: CGPoint) -> Obj?
    {
        .circle(CircleObject(position: Vector2(point)))
    }

    var reducer: Reducer<World.Action, World.State<Obj>, World.Environment>
    {
        World
            .reducer(
                tick: World.tickForObjects(self.step),
                tap: { objects, point in
                    if let object = exampleTapToMakeObject(point: point) {
                        objects.append(object)
                    }
                },
                draggingObj: { $0.position = Vector2($1) },
                draggingEmptyArea: self.draggingEmptyArea,
                dragEndEmptyArea: self.dragEndEmptyArea
            )
    }
}

// MARK: - BobWorldExample

/// Pendulum example using `Bob`s.
protocol BobWorldExample: Example
{
    /// Custom logic called on every "tick" to modify `objects`, mainly to calculate angular acceleration.
    /// - Parameter Δt: Simulated delta time per tick.
    func step(objects: inout [Bob], boardSize: CGSize, Δt: Scalar)

    /// Custom logic called on "dragging empty area" to modify `objects`.
    func draggingEmptyArea(_ objects: inout [Bob], point: CGPoint)

    /// Custom logic called on "drag-end empty area" to modify `objects`.
    func dragEndEmptyArea(_ objects: inout [Bob])
}

extension BobWorldExample
{
    /// Default impl.
    func draggingEmptyArea(_ objects: inout [Bob], point: CGPoint) {}

    /// Default impl.
    func dragEndEmptyArea(_ objects: inout [Bob]) {}

    var reducer: Reducer<World.Action, World.State<Bob>, World.Environment>
    {
        World
            .reducer(
                tick: World.tickForBobs(self.step),
                tap: { _, _ in },
                draggingObj: { _, _ in },
                draggingEmptyArea: self.draggingEmptyArea,
                dragEndEmptyArea: self.dragEndEmptyArea
            )
    }
}
