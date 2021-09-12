import Foundation
import Actomaton

/// Game-of-Life pattern selection namespace.
public enum PatternSelect {}

extension PatternSelect
{
    public enum Action
    {
        case loadPatternFiles
        case didLoadPatternFiles([Section<Unit>])
        case didSelectPatternURL(URL)
        case didParsePatternFile(Pattern?)

        case updateSearchText(String)

        case favorite(Favorite.Action)
    }

    struct State: Equatable
    {
        var status: Status = .loading
        var searchText: String = ""
        var favorite: Favorite.State

        init(favoritePatternNames: [String] = [])
        {
            self.favorite = Favorite.State(patternNames: favoritePatternNames)
        }

        var filteredSections: [Section<Bool>]
        {
            let sections = self.status.loaded ?? []

            let lazySections2 = sections
                .lazy
                .filter { !$0.rows.isEmpty }
                .map { section in
                    Section<Bool>(
                        title: section.title,
                        rows: section.rows
                            .lazy
                            .filter { row in
                                if self.searchText.isEmpty { return true }
                                return row.title.lowercased().contains(self.searchText.lowercased())
                            }
                            .map { row in
                                Row<Bool>(
                                    title: row.title,
                                    url: row.url,
                                    isFavorite: self.favorite.patternNames.contains(row.title)
                                )
                            }
                    )
                }

            var sections2 = Array(lazySections2)

            sections2.insert(
                Section(
                    title: "Favorites",
                    rows: sections2.lazy.flatMap { $0.rows }
                        .filter { self.favorite.patternNames.contains($0.title) }
                ),
                at: 0
            )

            return sections2
        }

        enum Status: Equatable
        {
            case loading
            case loaded([Section<Unit>])
        }
    }

    struct Environment
    {
        var loadPatterns: () async throws -> [PatternSelect.Section<Unit>]
        var parseRunLengthEncoded: (URL) throws -> Pattern

        var favorite: Favorite.Environment

        init(
            loadPatterns: @escaping () async throws -> [PatternSelect.Section<Unit>],
            parseRunLengthEncoded: @escaping (URL) throws -> Pattern,
            favorite: Favorite.Environment
        )
        {
            self.loadPatterns = loadPatterns
            self.parseRunLengthEncoded = parseRunLengthEncoded
            self.favorite = favorite
        }
    }

    static func reducer() -> Reducer<Action, State, Environment>
    {
        .combine(
            self._reducer(),

            Favorite.reducer()
                .contramap(action: /Action.favorite)
                .contramap(state: \.favorite)
                .contramap(environment: { $0.favorite })
        )
    }

    private static func _reducer() -> Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case .loadPatternFiles:
                return Effect {
                    do {
                        let patterns = try await environment.loadPatterns()
                        return Action.didLoadPatternFiles(patterns)
                    }
                    catch {
                        print("===> loadPatterns error: ", error.localizedDescription)
                        return Action.didLoadPatternFiles([])
                    }
                }

            case let .didLoadPatternFiles(sections):
                state.status = .loaded(sections)

            case let .didSelectPatternURL(url):
                state.status = .loading

                return Effect {
                    let pattern = try? Pattern.parseRunLengthEncoded(url: url)
                    return Action.didParsePatternFile(pattern)
                }

            case .didParsePatternFile:
                break

            case let .updateSearchText(text):
                state.searchText = text

            case .favorite:
                break
            }

            return .empty
        }
    }
}

// MARK: - Section & Row

extension PatternSelect
{
    public struct Section<Fav>: Identifiable, Equatable where Fav: Equatable
    {
        var title: String
        var rows: [Row<Fav>]

        public var id: String { self.title }
    }

    struct Row<Fav>: Identifiable, Equatable where Fav: Equatable
    {
        var title: String
        var url: URL
        var isFavorite: Fav

        var id: String { self.title }
    }

    public struct Unit: Equatable {}
}

// MARK: - Enum Properties

extension PatternSelect.State.Status
{
    public var isLoading: Bool
    {
        guard case .loading = self else { return false }
        return true
    }

    public var loaded: [PatternSelect.Section<PatternSelect.Unit>]?
    {
        guard case let .loaded(value) = self else { return nil }
        return value
    }
}
