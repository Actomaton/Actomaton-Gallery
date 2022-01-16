import SwiftUI
import ActomatonStore

@MainActor
public struct TabView<InnerAction, InnerState, TabID>: View
    where InnerState: Equatable, TabID: Hashable
{
    private let store: Store<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>>.Proxy
    private let content: (TabID, Store<InnerAction, InnerState>.Proxy) -> AnyView

    public init<V: View>(
        store: Store<Action<InnerAction, InnerState, TabID>, State<InnerState, TabID>>.Proxy,
        @ViewBuilder content: @escaping (TabID, Store<InnerAction, InnerState>.Proxy) -> V
    )
    {
        self.store = store
        self.content = { AnyView(content($0, $1)) }
    }

    public var body: some View
    {
        // WARNING:
        // `SwiftUI.TabView`'s "More Tab" doesn't work well if `selection` is used.
        SwiftUI.TabView(selection: store.currentTabID.stateBinding(onChange: { .changeTab($0) })) {
        // SwiftUI.TabView {
            ForEach(store: store.tabs, id: \.id) { tabStore in
                let tab = tabStore.state

                self
                    .content(
                        tab.id,
                        tabStore.inner
                            .contramap(action: { Action<InnerAction, InnerState, TabID>.inner(tab.id, $0) })
                    )
                    .tabItem {
                        tab.tabItemIcon
                        Text(tab.tabItemTitle)
                    }
                    .tag(tab.id)
            }
        }
    }
}
