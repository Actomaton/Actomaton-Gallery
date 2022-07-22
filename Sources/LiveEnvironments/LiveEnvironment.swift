import CommonEffects

/// Protocol for derived environment from `CommonEffects` that can make ``live`` enviornment.
public protocol LiveEnvironment
{
    init(commonEffects: CommonEffects)
}

extension LiveEnvironment
{
    public static var live: Self
    {
        .init(commonEffects: .live)
    }
}
