import SwiftUI
import ActomatonStore
import UserSession

@MainActor
public struct SettingsView: View
{
    private let store: Store<Action, State>.Proxy
    private let usesNavigationView: Bool

    public init(store: Store<Action, State>.Proxy, usesNavigationView: Bool)
    {
        self.store = store
        self.usesNavigationView = usesNavigationView
    }

    public var body: some View
    {
        if self.usesNavigationView {
            NavigationView {
                self.form
                    .navigationTitle("Settings")
            }
        }
        else {
            self.form
        }
    }

    private var form: some View
    {
        Form {
            Section {
                HStack {
                    let user = self.store.state.user

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

            Section {
                Button("Insert Tab") {
                    self.store.send(.insertTab)
                }
                Button("Remove Tab") {
                    self.store.send(.removeTab)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SettingsView(
            store: .init(
                state: .constant(.init(user: .anonymous)),
                send: { _ in }
            ),
            usesNavigationView: true
        )
            .previewLayout(.sizeThatFits)
    }
}
