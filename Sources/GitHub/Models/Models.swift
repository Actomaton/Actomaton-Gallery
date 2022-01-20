import UIKit
import Utilities

public struct Repository: Decodable, Identifiable, Equatable, Sendable
{
    public let id: Int
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let htmlUrl: URL
    let owner: Owner

    public init(
        id: Int,
        fullName: String,
        description: String?,
        stargazersCount: Int,
        htmlUrl: URL,
        owner: Owner
    )
    {
        self.id = id
        self.fullName = fullName
        self.description = description
        self.stargazersCount = stargazersCount
        self.htmlUrl = htmlUrl
        self.owner = owner
    }

    public struct Owner: Decodable, Identifiable, Equatable, Sendable
    {
        public let id: Int
        let login: String
        let avatarUrl: URL

        public init(id: Int, login: String, avatarUrl: URL)
        {
            self.id = id
            self.login = login
            self.avatarUrl = avatarUrl
        }
    }
}

/// Mainly for decoding 403 API limit error.
public struct Error: Swift.Error, Decodable
{
    let message: String
}

public struct SearchRepositoryResponse: Decodable
{
    var value: Either<[Repository], GitHub.Error>

    public init(from decoder: Decoder) throws
    {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = .left(try container.decode([Repository].self, forKey: .items))
        }
        catch {
            let container = try decoder.singleValueContainer()
            self.value = .right(try container.decode(GitHub.Error.self))
        }
    }

    private enum CodingKeys: CodingKey
    {
        case items
    }
}
