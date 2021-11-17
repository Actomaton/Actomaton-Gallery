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
            ForEach(store.tabs.$state, id: \.id) { tab in
                let tab_ = tab.wrappedValue
                
                let childStore = Store.Proxy(state: tab.state, send: self.store.send)
                    .contramap(action: { Action<InnerAction, InnerState, TabID>.inner(tab_.id, $0) })

                self.content(tab_.id, childStore)
                    .tabItem {
                        tab_.tabItemIcon
                        Text(tab_.tabItemTitle)
                    }
                    .tag(tab_.id)
            }
        }
    }
}
