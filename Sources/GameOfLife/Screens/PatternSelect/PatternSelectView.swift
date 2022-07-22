import SwiftUI
import ActomatonUI
import CommonUI

@MainActor
struct PatternSelectView: View
{
    private let store: Store<PatternSelect.Action, PatternSelect.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<PatternSelect.Action, PatternSelect.State>

    init(store: Store<PatternSelect.Action, PatternSelect.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
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
                text: self.viewStore.binding(
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
                    .opacity(self.viewStore.searchText == "" ? 0 : 1)
            }
        }
        .padding(10)
    }

    private func form() -> some View
    {
        List {
            if self.viewStore.status.isLoading {
                ActivityIndicatorView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            else {
                ForEach(self.viewStore.filteredSections) { section in
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

struct GameOfLife_PatternSelectView_Previews: PreviewProvider
{
    @ViewBuilder
    static func makePreviews(environment: PatternSelect.Environment, isMultipleScreens: Bool) -> some View
    {
        let gameOfLifeView = PatternSelectView(
            store: Store(
                state: .init(),
                reducer: PatternSelect.reducer(),
                environment: environment
            )
            .noEnvironment
        )

        gameOfLifeView
            .previewDisplayName("Portrait")
//            .previewInterfaceOrientation(.portrait)

//        gameOfLifeView
//            .previewDisplayName("Landscape")
//            .previewInterfaceOrientation(.landscapeRight)
    }

    /// - Note: Uses mock environment.
    static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                loadPatterns: { [] },
                parseRunLengthEncoded: { _ in .glider },
                favorite: .init(loadFavorites: { [] }, saveFavorites: { _ in })
            ),
            isMultipleScreens: true
        )
    }
}
