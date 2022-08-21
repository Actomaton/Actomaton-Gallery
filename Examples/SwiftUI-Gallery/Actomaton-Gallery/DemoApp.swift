import SwiftUI
import Inject

@main
struct DemoApp: App
{
    var body: some Scene
    {
        WindowGroup {
            InjectedAppView().enableInjection()
        }
    }
}
