import CommonEffects

/// Protocol for derived environment from `CommonEffects` that can make ``live`` enviornment.
public protocol LiveEnvironment
{
    @MainActor
    init(commonEffects: CommonEffects)
}

extension LiveEnvironment
{
    @MainActor
    public static var live: Self
    {
        .init(commonEffects: .live)
    }
}
