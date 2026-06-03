import CoreGraphics
import CommonInterfaces
@_exported import Geometry
import CanvasPlayer

// SwiftUI `CanvasPlayerUI` facade over the platform-agnostic `CanvasPlayer`.
//
// Re-exposes the core's `Action` / `State` / `Environment` / `reducer`, and bridges
// CoreGraphics `CGPoint` / `CGSize` <-> the portable
// `Geometry.Point` / `Geometry.Size` carried by the core's actions and state.

// MARK: - Re-exported core types

public typealias Action = CanvasPlayer.Action
public typealias State<CanvasState: Equatable & Sendable> = CanvasPlayer.State<CanvasState>
public typealias Environment = CanvasPlayer.Environment

public func reducer<CanvasState>() -> Reducer<Action, State<CanvasState>, Environment>
    where CanvasState: Equatable & Sendable
{
    CanvasPlayer.reducer()
}

public func cancelAllEffectsPredicate(id: any EffectID) -> Bool
{
    CanvasPlayer.cancelAllEffectsPredicate(id: id)
}

// MARK: - CoreGraphics bridging

extension Geometry.Point
{
    public init(_ point: CGPoint)
    {
        self.init(x: Double(point.x), y: Double(point.y))
    }
}

extension CGPoint
{
    public init(_ point: Geometry.Point)
    {
        self.init(x: point.x, y: point.y)
    }
}

extension Geometry.Size
{
    public init(_ size: CGSize)
    {
        self.init(width: Double(size.width), height: Double(size.height))
    }
}

extension CGSize
{
    public init(_ size: Geometry.Size)
    {
        self.init(width: size.width, height: size.height)
    }
}
