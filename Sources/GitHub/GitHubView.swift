import SwiftUI
import ActomatonStore

public struct GitHubView: View
{
    private let store: Store<GitHub.Action, GitHub.State>.Proxy

    public init(store: Store<GitHub.Action, GitHub.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        VStack {
            searchBar()

            Divider()

            List {
                ForEach(self.store.state.items.indices, id: \.self) { index in
                    self.itemRow(at: index)
                        .onTapGesture {
                            self.store.send(.tapRow(at: index))
                        }
                }
            }
            .sheet(isPresented: self.store.$state.isWebViewPresented) {
                WebView(url: self.store.state.selectedWebURL!)
            }
        }
        .navigationBarItems(
            trailing: ActivityIndicatorView()
                .opacity(self.store.state.isLoading ? 1 : 0)
        )
        .onAppear { self.store.send(.onAppear) }
        .alert(item: self.store.$state.errorMessage) {
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
                text: self.store.stateBinding(
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
                    .opacity(self.store.state.searchText == "" ? 0 : 1)
            }
        }
        .padding(10)
    }

    private func itemRow(at visibleIndex: Int) -> some View
    {
        let item = self.store.state.items[visibleIndex]
        let image = self.store.state.imageLoader.images[item.owner.avatarUrl]

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

struct GitHubView_Previews: PreviewProvider
{
    static var previews: some View
    {
        GitHubView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
