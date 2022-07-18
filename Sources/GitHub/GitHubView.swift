import SwiftUI
import ActomatonUI
import CommonUI

@MainActor
public struct GitHubView: View
{
    private let store: Store<GitHub.Action, GitHub.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<GitHub.Action, GitHub.State>

    public init(store: Store<GitHub.Action, GitHub.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        VStack {
            searchBar()

            Divider()

            List {
                ForEach(self.viewStore.items.indices, id: \.self) { index in
                    self.itemRow(at: index)
                        .onTapGesture {
                            self.store.send(.tapRow(at: index))
                        }
                }
            }
            .sheet(isPresented: self.viewStore.directBinding.isWebViewPresented) {
                WebView(url: self.viewStore.selectedWebURL!)
            }
        }
        .navigationBarItems(
            trailing: ActivityIndicatorView()
                .opacity(self.viewStore.isLoading ? 1 : 0)
        )
        .onAppear { self.store.send(.onAppear) }
        .alert(item: self.viewStore.directBinding.errorMessage) {
            Alert(
                title: Text("Network Error"),
                message: Text("\($0.message)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func searchBar() -> some View
    {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                "Search",
                // IMPORTANT:
                // Requires indirect state-to-action conversion binding here because
                // `Action.updateSearchText` will trigger side-effect
                // which is not possible via direct state binding.
                text: self.viewStore.binding(
                    get: { $0.searchText },
                    onChange: GitHub.Action.updateSearchText
                )
                // text: self.store.$state.searchText
            )

            Button(action: {
                self.store.send(.updateSearchText(""))
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .opacity(self.viewStore.searchText == "" ? 0 : 1)
            }
        }
        .padding(10)
    }

    private func itemRow(at visibleIndex: Int) -> some View
    {
        let item = self.viewStore.items[visibleIndex]
        let image = self.viewStore.imageLoader.images[item.owner.avatarUrl]

        return HStack(alignment: .top) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                    .frame(width: 80)
            }

            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "doc.text")
                    Text(item.fullName)
                        .bold()
                }

                // Show text if description exists
                item.description
                    .map(Text.init)?
                    .lineLimit(nil)

                HStack {
                    Image(systemName: "star")
                    Text("\(item.stargazersCount)")
                }
            }
        }
        .padding(.vertical, 10)
    }
}

public struct GitHubView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: GitHub.Environment, isMultipleScreens: Bool) -> some View
    {
        GitHubView(
            store: Store(
                state: .init(),
                reducer: GitHub.reducer,
                environment: environment
            )
            .noEnvironment
        )
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                fetchRepositories: { _ in throw CancellationError() },
                fetchImage: { _ in nil },
                searchRequestDelay: 1,
                imageLoadMaxConcurrency: 1
            ),
            isMultipleScreens: true
        )
    }
}
