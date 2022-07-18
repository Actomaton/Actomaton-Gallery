import ActomatonUI
import Counter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import GameOfLife

/// ExampleList namespace.
enum ExampleList {}

extension ExampleList
{
    public enum Action: Sendable
    {
        case showExample(AnyExample)

        case debugIncrement
    }

    public struct State: Equatable, Sendable
    {
        public let examples: [AnyExample]

        public var debugCount: Int = 0

        public init(examples: [AnyExample])
        {
            self.examples = examples
        }

        public static func == (l: Self, r: Self) -> Bool
        {
            l.examples.map(\.exampleTitle) == r.examples.map(\.exampleTitle)
        }
    }

    typealias Environment = ()

    public enum Route
    {
        case showExample(AnyExample)
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
