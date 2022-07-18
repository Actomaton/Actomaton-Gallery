import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct TabView<InnerAction, InnerState, InnerEnvironment, TabID>: View
where InnerAction: Sendable, InnerState: Equatable & Sendable,
      InnerEnvironment: Sendable, TabID: Hashable & Sendable
{
    private let store: Store<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, InnerEnvironment>
    private let content: (TabID, Store<InnerAction, InnerState, InnerEnvironment>) -> AnyView

    @ObservedObject
    private var viewStore: ViewStore<Action<InnerAction, InnerState, TabID>, [TabItem<InnerState, TabID>.Common]>

    public init<V: View>(
        store: Store<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>, InnerEnvironment>,
        @ViewBuilder content: @escaping (TabID, Store<InnerAction, InnerState, InnerEnvironment>) -> V
    )
    {
        let _ = Debug.print("TabView.init")

        self.store = store
        self.content = { AnyView(content($0, $1)) }

        // Observe `tabs` but ignores `inner` state changes for optimized rendering.
        self.viewStore = store
            .map(state: \.tabs)
            .map(states: \.common)
            .viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("TabView.body")

        WithViewStore(store.map(state: \.currentTabID)) { viewStore in
            // WARNING:
            // `SwiftUI.TabView`'s "More Tab" doesn't work well if `selection` is used.
            SwiftUI.TabView(selection: viewStore.binding(onChange: { .changeTab($0) })) {
                ForEach(store: store.map(state: \.tabs), id: \.id) { tabStore in
                    let tab = tabStore.viewStore.state

                    self
                        .content(
                            tab.common.id,
                            tabStore
                                .map(state: \.inner)
                                .contramap(action: { Action<InnerAction, InnerState, TabID>.inner(tab.id, $0) })
                        )
                        .tabItem {
                            tab.common.tabItemIcon
                            Text(tab.common.tabItemTitle)
                        }
                        .tag(tab.common.id)
                }
            }
        }
    }
}
