import SwiftUI
import ActomatonUI
import UserSession

@MainActor
public struct SettingsView: View
{
    private let store: Store<Action, State, Void>
    private let usesNavigationView: Bool

    public init(store: Store<Action, State, Void>, usesNavigationView: Bool)
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

    @ViewBuilder
    private var form: some View
    {
        WithViewStore(store) { viewStore in
            Form {
                Section {
                    HStack {
                        let user = viewStore.user

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
}

struct SettingsView_Previews: PreviewProvider
{
    static var previews: some View
    {
        SettingsView(
            store: .init(
                state: .init(user: .anonymous),
                reducer: SettingsScene.reducer
            ),
            usesNavigationView: true
        )
    }
}
