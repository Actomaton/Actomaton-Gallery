import SwiftUI
import ActomatonStore

@MainActor
public struct VideoDetectorAppView: View
{
    @StateObject
    private var store: Store<VideoDetector.Action, VideoDetector.State, VideoDetector.Environment>

    public init()
    {
        let store = Store<VideoDetector.Action, VideoDetector.State, VideoDetector.Environment>(
            state: VideoDetector.State(),
            reducer: VideoDetector.reducer,
            environment: ()
        )
        self._store = StateObject(wrappedValue: store)
    }

    public var body: some View
    {
        // IMPORTANT: Pass `Store.Proxy` to children.
        VideoDetectorView(store: self.store.proxy)
    }
}
