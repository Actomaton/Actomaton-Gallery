import SwiftUI
import ActomatonStore
import Tab
import Home
import Counter

@MainActor
public struct RootView: View
{
    private let store: Store<Action, State>.Proxy

    public init(store: Store<Action, State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            Tab.TabView(store: self.store.contramap(action: Action.tab)) { tabID, childStore in
                if let childStore_ = childStore
                    .contramap(action: TabCaseAction.home)[casePath: /TabCaseState.home]
                    .traverse(\.self)
                {
                    HomeView(store: childStore_)
                }
                else if let childStore_ = childStore
                            .contramap(action: TabCaseAction.counter)[casePath: /TabCaseState.counter]
                            .traverse(\.self)
                {
                    CounterView(store: childStore_)
                }
                else {
                    Text("Should never reach here")
                }
            }

            if self.store.state.isDebuggingTab {
                self.tabDebugView()
            }
        }
//        .onOpenURL { url in
//            print("[openURL]", url)
//            store.send(.universalLink(url))
//        }
    }

    private func tabDebugView() -> some View
    {
        HStack {
            Text(Image(systemName: "sidebar.squares.left")).bold() + Text(" TAB").bold()
            Spacer()
            Button("Insert Tab") {
                self.store.send(.insertRandomTab(index: Int.random(in: 0 ... 4)))
            }
            Spacer()
            Button("Delete Tab") {
                self.store.send(.removeTab(index: Int.random(in: 0 ... 4)))
            }
            Spacer()
        }
        .padding()
    }
}
