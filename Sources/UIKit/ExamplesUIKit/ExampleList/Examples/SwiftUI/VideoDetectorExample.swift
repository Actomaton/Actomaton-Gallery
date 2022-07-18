import SwiftUI
import ActomatonUI
import VideoDetector
import ExampleListUIKit

public struct VideoDetectorExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "video") }

    @MainActor
    public func build() -> UIViewController
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
