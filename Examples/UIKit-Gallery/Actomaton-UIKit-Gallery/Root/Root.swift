import ActomatonStore
import Counter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import GameOfLife

/// Root namespace.
enum Root {}

extension Root
{
    public enum Action
    {
        case showExample(Example)

        case debugIncrement
    }

    public struct State
    {
        public let examples: [Example]

        public var debugCount: Int = 0

        public init(examples: [Example])
        {
            self.examples = examples
        }
    }

    typealias Environment = ()

    public enum Route
    {
        case showExample(Example)
    }

    public static var reducer: Reducer<Action, State, SendRouteEnvironment<Environment, Route>>
    {
        .init { action, state, env in
            switch action {
            case let .showExample(example):
                return .fireAndForget {
                    env.sendRoute(.showExample(example))
                }

            case .debugIncrement:
                state.debugCount += 1
                return .empty
            }
        }
    }
}
