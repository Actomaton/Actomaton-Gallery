import Foundation

/// UserSession error.
public struct Error: LocalizedError, Equatable
{
    public let errorDescription: String?

    private init(_ errorDescription: String)
    {
        self.errorDescription = errorDescription
    }

    public static let loginFailed = Error("Login failed")
    public static let sessionExpired = Error("Session Expired")
}
