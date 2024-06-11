import UIKit
import SwiftUI
import ActomatonUI

public enum TabBuilder
{
    @MainActor
    public static func build<TabID>(
        store: Store<Action<TabID>, State<TabID>, Environment>
    ) -> UIViewController
        where TabID: Equatable
    {
        return TabBarController<TabID>(store: store)
    }
}
