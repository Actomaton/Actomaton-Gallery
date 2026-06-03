import Foundation

public struct Repository: Decodable, Identifiable, Equatable, Sendable
{
    public let id: Int
    public let fullName: String
    public let description: String?
    public let stargazersCount: Int
    public let htmlUrl: URL
    public let owner: Owner

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
        public let login: String
        public let avatarUrl: URL

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
    /// Either a list of repositories, or a decoded API error (e.g. 403 rate-limit).
    enum Outcome
    {
        case repositories([Repository])
        case failure(Error)
    }

    var value: Outcome

    public init(from decoder: Decoder) throws
    {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.value = .repositories(try container.decode([Repository].self, forKey: .items))
        }
        catch {
            let container = try decoder.singleValueContainer()
            self.value = .failure(try container.decode(Error.self))
        }
    }

    private enum CodingKeys: CodingKey
    {
        case items
    }
}
