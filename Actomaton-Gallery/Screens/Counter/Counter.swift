import Actomaton

/// Counter example namespace.
enum Counter {}

extension Counter
{
    enum Action: String, CustomStringConvertible
    {
        case increment
        case decrement

        var description: String { return self.rawValue }
    }

    struct State: Equatable
    {
        var count: Int = 0
    }

    static var reducer: Reducer<Action, State, Environment>
    {
        .init { action, state, _ in
            switch action {
            case .increment:
                state.count += 1
                return .empty
            case .decrement:
                state.count -= 1
                return .empty
            }
        }
    }

    typealias Environment = ()
}
