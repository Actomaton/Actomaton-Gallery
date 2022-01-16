import Actomaton

// MARK: - Action

public enum Action<InnerAction, InnerState, TabID>
    where InnerState: Equatable, TabID: Hashable
{
    case insertTab(TabItem<InnerState, TabID>, index: Int)
    case removeTab(TabID)
    case changeTab(TabID)

    case inner(TabID, InnerAction)
}

// MARK: - State

public struct State<InnerState, TabID>: Equatable
    where InnerState: Equatable, TabID: Hashable
{
    public var tabs: [TabItem<InnerState, TabID>]
    public var currentTabID: TabID

    public init(tabs: [TabItem<InnerState, TabID>], currentTabID: TabID)
    {
        self.tabs = tabs
        self.currentTabID = currentTabID
    }
}

// MARK: - Reducer

public func reducer<InnerAction, InnerState, Environment, TabID>(
    innerReducers: @escaping (TabID) -> Reducer<InnerAction, InnerState, Environment>
) -> Reducer<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, Environment>
    where TabID: Hashable
{
    .combine(
        tabChildrenReducer(innerReducers: innerReducers),
        changeTabReducer(),
        insertTabReducer(),
        removeTabReducer()
    )
}

private func changeTabReducer<InnerAction, InnerState, Environment, TabID>()
    -> Reducer<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, Environment>
    where TabID: Hashable
{
    .init { action, state, environment in
        guard case let .changeTab(tabID) = action else { return .empty }

        state.currentTabID = tabID
        return .empty
    }
}

private func tabChildrenReducer<InnerAction, InnerState, Environment, TabID>(
    innerReducers: @escaping (TabID) -> Reducer<InnerAction, InnerState, Environment>
) -> Reducer<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, Environment>
    where TabID: Hashable
{
    .init { action, state, environment in
        guard case let .inner(tabID, innerAction) = action else { return .empty }

        // TODO: This computation should be cached.
        let reducers = state.tabs
            .lazy
            .map { ($0.id, innerReducers($0.id)) }
            .enumerated()
            .map { index, args -> Reducer<InnerAction, State<InnerState, TabID>, Environment> in
                let (tabID_, reducer) = args

                guard tabID == tabID_ else { return .empty }

                let stateKeyPath = \State<InnerState, TabID>.tabs[index].inner

                return reducer
                    .contramap(state: stateKeyPath)
            }

        let combinedReducer = Reducer.combine(reducers)

        let eff = combinedReducer.run(innerAction, &state, environment)
        return eff.map { .inner(tabID, $0) }
    }
}

private func insertTabReducer<InnerAction, InnerState, Environment, TabID>()
    -> Reducer<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, Environment>
    where TabID: Hashable
{
    .init { action, state, environment in
        guard case let .insertTab(tab, index) = action else { return .empty }

        state.tabs.insert(tab, at: min(max(index, 0), state.tabs.count))

        return .empty
    }
}

private func removeTabReducer<InnerAction, InnerState, Environment, TabID>()
    -> Reducer<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, Environment>
    where TabID: Hashable
{
    .init { action, state, environment in
        guard case let .removeTab(tabID) = action else { return .empty }

        if let index = state.tabs.firstIndex(where: { $0.id == tabID }) {
            state.tabs.remove(at: index)
        }

        return .empty
    }
}
