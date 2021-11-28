import UIKit
import SwiftUI
import ActomatonStore

public enum TabBuilder
{
    @MainActor
    public static func build<TabID>(
        store: Store<Action<TabID>, State<TabID>>.ObservableProxy
    ) -> UIViewController
        where TabID: Equatable
    {
        return TabBarController<TabID>(store: store)
    }
}
