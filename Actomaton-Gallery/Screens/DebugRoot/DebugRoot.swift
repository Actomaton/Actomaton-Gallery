import Combine
import Actomaton

/// DebugRoot namespace.
enum DebugRoot {}

extension DebugRoot
{
    enum Action
    {
        case timeTravel(TimeTravel.Action<Root.Action>)
    }

    struct State: Equatable
    {
        var timeTravel: TimeTravel.State<Root.State>
        let usesTimeTravel: Bool

        /// For debugging purpose.
        var isDebug: Bool = false
        {
            didSet {
                print("===> Root.State = \(self)".noAppPrefix)
            }
        }

        init(inner state: Root.State, usesTimeTravel: Bool)
        {
            self.timeTravel = .init(inner: state)
            self.usesTimeTravel = usesTimeTravel
        }
    }

    static func reducer(usesTimeTravel: Bool = true) -> Reducer<Action, State, Environment>
    {
        let rootReducer: Reducer<Action, State, Environment> = Root.reducer
            .contramap(action: /TimeTravel.Action<Root.Action>.inner)
            .contramap(action: /Action.timeTravel)
            .contramap(state: \TimeTravel.State<Root.State>.inner)
            .contramap(state: \State.timeTravel)

        if usesTimeTravel {
            return .combine(
                rootReducer,

                // Important: TimeTravel mapping needs to be called after `Root.effectMapping` (after `Root.State` changed).
                TimeTravel.reducer()
                    .contramap(environment: { TimeTravel.Environment(inner: $0) })
                    .contramap(action: /Action.timeTravel)
                    .contramap(state: \State.timeTravel)
            )
        }
        else {
            return rootReducer
        }
    }

    typealias Environment = Actomaton_Gallery.Environment
}

// MARK: - Enum Properties

extension DebugRoot.Action
{
    var timeTravel: TimeTravel.Action<Root.Action>?
    {
        get {
            guard case let .timeTravel(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravel = self, let newValue = newValue else { return }
            self = .timeTravel(newValue)
        }
    }
}

// MARK: - Private

extension String
{
    fileprivate var noAppPrefix: String
    {
        self.replacingOccurrences(of: "Actomaton_Gallery.", with: "")
    }
}
