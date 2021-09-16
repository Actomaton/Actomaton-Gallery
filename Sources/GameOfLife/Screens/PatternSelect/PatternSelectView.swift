import SwiftUI
import ActomatonStore

@MainActor
struct PatternSelectView: View
{
    private let store: Store<PatternSelect.Action, PatternSelect.State>.Proxy

    init(store: Store<PatternSelect.Action, PatternSelect.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack(spacing: 0) {
            self.searchBar()

            Divider()

            self.form()
        }
    }

    private func searchBar() -> some View
    {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                "Search",
                text: self.store.stateBinding(
                    get: { $0.searchText },
                    onChange: PatternSelect.Action.updateSearchText
                )
            )
                .autocapitalization(.none)
                .disableAutocorrection(true)

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

    private func form() -> some View
    {
        List {
            if self.store.state.status.isLoading {
                ActivityIndicatorView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            else {
                ForEach(self.store.state.filteredSections) { section in
                    if section.rows.isEmpty {
                        EmptyView()
                    }
                    else {
                        Section(header: Text(section.title)) {
                            ForEach(section.rows) { row in
                                self.formRow(row)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Select Pattern", displayMode: .inline)
        .onAppear {
            self.store.send(.loadPatternFiles)
        }
    }

    private func formRow(_ row: PatternSelect.Row<Bool>) -> some View
    {
        HStack {
            Text(row.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .onTapGesture {
                    self.store.send(.didSelectPatternURL(row.url))
                }

            Spacer()

            Image(systemName: "star")
                .foregroundColor(row.isFavorite ? Color.yellow : nil)
                .onTapGesture {
                    self.store.send(.favorite(
                        row.isFavorite
                            ? .removeFavorite(patternName: row.title)
                            : .addFavorite(patternName: row.title)
                    ))
                }
        }
    }
}

// MARK: - Preview

struct PatternSelectView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let gameOfLifeView = PatternSelectView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )

        return Group {
            gameOfLifeView.previewLayout(.sizeThatFits)
                .previewDisplayName("Portrait")

            gameOfLifeView.previewLayout(.fixed(width: 568, height: 320))
                .previewDisplayName("Landscape")
        }
    }
}
