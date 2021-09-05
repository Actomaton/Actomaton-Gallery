import Combine
import ActomatonStore
import Dispatch

/// Simple time-traveller for Actomaton Architecture.
enum TimeTravel {}

extension TimeTravel
{
    enum Action<InnerAction>
    {
        case timeTravelStepper(diff: Int)
        case timeTravelSlider(sliderValue: Double)
        case _didTimeTravel
        case resetHistories

        case inner(InnerAction)
    }

    struct State<InnerState: Equatable>: Equatable
    {
        var inner: InnerState

        fileprivate(set) var histories: [InnerState] = []

        fileprivate(set) var timeTravellingIndex: Int = 0

        // Workaround flag for avoiding SwiftUI iOS navigation binding issue
        // where `isActive = false` binding is called during time-travelling.
        fileprivate(set) var isTimeTravelling: Bool = false

        init(inner: InnerState)
        {
            self.inner = inner
            self.histories.append(inner)
        }

        var timeTravellingSliderRange: ClosedRange<Double>
        {
            let count = self.histories.count

            // NOTE: `0 ... 0` is not allowed in `Slider`.
            return count > 1
                ? 0 ... Double(count - 1)
                : -1 ... 0
        }

        var timeTravellingSliderValue: Double
        {
            get { Double(timeTravellingIndex) }
            set { assertionFailure("Should be replaced by `Store.Proxy.stateBinding`") }
        }

        var canTimeTravel: Bool
        {
            self.histories.count > 1
        }

        mutating func appendHistory(_ state: InnerState)
        {
            // Ignore same state.
            guard self.histories.last != state else { return }

            self.histories.removeSubrange((self.timeTravellingIndex + 1)...)
            self.histories.append(state)
            self.timeTravellingIndex += 1
        }
    }

    /// - Important: This mapping needs to be called after `InnerState` has changed.
    static func reducer<InnerAction, InnerState, InnerEnvironment>()
        -> Reducer<Action<InnerAction>, State<InnerState>, Environment<InnerEnvironment>>
    {
        func tryTimeTravel(state: inout State<InnerState>, newIndex: Int, environment: Environment<InnerEnvironment>)
            -> Effect<Action<InnerAction>>
        {
            guard !state.histories.isEmpty && newIndex >= 0 && newIndex < state.histories.count else {
                return .empty
            }

            // Load history.
            state.inner = state.histories[newIndex]

            // NOTE: Modify other states after history is loaded.
            state.timeTravellingIndex = newIndex
            state.isTimeTravelling = true

            // Workaround effect for changing to `isTimeTravelling = false` after delay.
            return Just(Action._didTimeTravel)
                .delay(for: environment.didTimeTravelDelay, scheduler: DispatchQueue.main)
                .toEffect()
        }

        return .init { action, state, environment in
            switch action {
            case let .timeTravelSlider(sliderValue):
                guard sliderValue >= 0 else { return .empty }

                let newIndex = Int(sliderValue)
                return tryTimeTravel(state: &state, newIndex: newIndex, environment: environment)

            case let .timeTravelStepper(diff):
                guard diff != 0 else { return .empty }

                let newIndex = state.timeTravellingIndex + diff
                return tryTimeTravel(state: &state, newIndex: newIndex, environment: environment)

            case ._didTimeTravel:
                state.isTimeTravelling = false

            case .resetHistories:
                state.histories.removeAll()
                state.histories.append(state.inner)
                state.timeTravellingIndex = 0

            default:
                // IMPORTANT:
                // Guard `appendHistory` while `isTimeTravelling` to avoid SwiftUI iOS navigation binding issue
                // where `isActive = false` binding is called during time-travelling.
                guard !state.isTimeTravelling else {
                    return .empty
                }

                state.appendHistory(state.inner)
            }

            return .empty
        }
    }

    struct Environment<InnerEnvironment>
    {
        let inner: InnerEnvironment

        /// Workaround delay.
        let didTimeTravelDelay: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.1)
    }
}

// MARK: - Enum Properties

extension TimeTravel.Action
{
    var timeTravelStepper: Int?
    {
        get {
            guard case let .timeTravelStepper(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravelStepper = self, let newValue = newValue else { return }
            self = .timeTravelStepper(diff: newValue)
        }
    }

    var timeTravelSlider: Double?
    {
        get {
            guard case let .timeTravelSlider(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravelSlider = self, let newValue = newValue else { return }
            self = .timeTravelSlider(sliderValue: newValue)
        }
    }

    var _didTimeTravel: Void?
    {
        guard case ._didTimeTravel = self else { return nil }
        return ()
    }

    var resetHistories: Void?
    {
        get {
            guard case .resetHistories = self else { return nil }
            return ()
        }
        set {
            guard case .resetHistories = self, case .some = newValue else { return }
            self = .resetHistories
        }
    }

    var inner: InnerAction?
    {
        get {
            guard case let .inner(value) = self else { return nil }
            return value
        }
        set {
            guard case .inner = self, let newValue = newValue else { return }
            self = .inner(newValue)
        }
    }
}
