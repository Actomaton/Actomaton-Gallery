import SwiftUI
import ActomatonStore
import UserSession

@MainActor
public struct SettingsView: View
{
    private let store: Store<Action, State>.Proxy

    public init(store: Store<Action, State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        NavigationView {
            Form {
                Section {
                    HStack {
                        let user = self.store.state.user ?? .anonymous

                        user.icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 44)
                        Text(user.name)
                            .font(.title2)
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button("Logout") {
                        self.store.send(.logout)
                    }
                    Button("Show Onboarding") {
                        self.store.send(.onboarding)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SettingsView(
            store: .init(
                state: .constant(.init(user: nil)),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
