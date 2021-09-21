public struct SessionID: Hashable
{
    internal var value: UInt64

    mutating func increment() {
        self.value &+= 1
    }

    public static let testID = SessionID(value: 12345)
}
