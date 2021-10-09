import SwiftUI
import ActomatonStore
import VideoDetector
import ExampleListUIKit

struct VideoDetectorExample: Example
{
    var exampleIcon: Image { Image(systemName: "video") }

    @MainActor
    func build() -> UIViewController
    {
        HostingViewController(
            store: Store(
                state: .init(),
                reducer: VideoDetector.reducer,
                environment: ()
            ),
            makeView: VideoDetectorView.init
        )
    }
}
