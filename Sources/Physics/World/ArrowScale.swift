public struct ArrowScale: Equatable
{
    public var velocityArrowScale: Float
    public var forceArrowScale: Float

    public init(
        velocityArrowScale: Float,
        forceArrowScale: Float
    )
    {
        self.velocityArrowScale = velocityArrowScale
        self.forceArrowScale = forceArrowScale
    }
}
