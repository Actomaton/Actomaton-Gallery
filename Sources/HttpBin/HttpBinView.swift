import SwiftUI
import ActomatonUI
import Utilities

@MainActor
public struct HttpBinView: View
{
    private let store: Store<HttpBin.Action, HttpBin.State, Void>

    public init(store: Store<HttpBin.Action, HttpBin.State, Void>)
    {
        let _ = Debug.print("HttpBinView.init")

        self.store = store
    }

    public var body: some View
    {
        let _ = Debug.print("HttpBinView.body")

        WithViewStore(store) { viewStore in
            VStack(spacing: 20) {
                Group {
                    if viewStore.isLoading {
                        ProgressView()
                    }
                    else {
                        Text(viewStore.text)
                            .font(.system(size: 24))
                    }
                }
                .frame(height: 150)

                Group {
                    Button("Fetch") {
                        store.send(.fetch)
                    }

                    Button("Cancel") {
                        store.send(.cancel)
                    }
                }
                .font(.system(size: 36))
            }
            .padding()
            .onAppear { self.store.send(.fetch) }
        }
    }
}

public struct HttpBinView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: HttpBin.Environment, isMultipleScreens: Bool) -> some View
    {
        HttpBinView(
            store: Store(
                state: .init(),
                reducer: HttpBin.reducer,
                environment: environment
            )
            .noEnvironment
        )
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(fetch: { throw CancellationError() }),
            isMultipleScreens: true
        )
    }
}
