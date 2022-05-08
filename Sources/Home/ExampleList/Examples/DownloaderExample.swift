import SwiftUI
import ActomatonStore
import Downloader

struct DownloaderExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.down.circle") }

    var exampleInitialState: Home.State.Current
    {
        .downloader(Downloader.State())
    }

    func exampleView(store: Store<Home.Action, Home.State, Home.Environment>.Proxy) -> AnyView
    {
        Self.exampleView(
            store: store,
            action: Home.Action.downloader,
            statePath: /Home.State.Current.downloader,
            makeView: DownloaderView.init
        )
    }
}
