import UIKit
import SwiftUI
import Combine
import ActomatonStore
import UserSession
import SettingsUIKit

@MainActor
public final class TabBarController<TabID>: UITabBarController
    where TabID: Equatable & Sendable
{
    private let store: Store<Action<TabID>, State<TabID>, Environment>.ObservableProxy
    private var cancellables: [AnyCancellable] = []

    public init(store: Store<Action<TabID>, State<TabID>, Environment>.ObservableProxy)
    {
        self.store = store

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder)
    {
        fatalError()
    }

    public override func viewDidLoad()
    {
        super.viewDidLoad()

        // Main presentation.
        // FIXME: Improve diffing.
        self.store.state
            .map { $0.tabs }
            .withNonDuplicatePrevious(initial: [])
            .sink { [weak self] oldTabs, newTabs in
                guard let self = self else { return }

                @MainActor
                func updateChildren()
                {
                    let childVCs = newTabs.map { tabItem -> UIViewController in
                        let vc = tabItem.build()
                        vc.title = tabItem.title
                        vc.tabBarItem = tabItem.tabBarItem

                        let navC = UINavigationController(rootViewController: vc)
                        navC.navigationBar.prefersLargeTitles = true
                        return navC
                    }

                    self.viewControllers = childVCs
                }

                if oldTabs.isEmpty {
                    updateChildren()
                    return
                }

                let currentTabIndex = self.selectedIndex
                let currentTabID = oldTabs[currentTabIndex].id
                let newTabIndex = newTabs.firstIndex(where: { $0.id == currentTabID })

                updateChildren()

                if let newTabIndex = newTabIndex {
                    self.selectedIndex = newTabIndex
                }
            }
            .store(in: &self.cancellables)
    }
}

extension Publisher
{
    /// Combines previous output which is not duplicate of current output, useful for sending both old & new outputs for UI diffing.
    fileprivate func withNonDuplicatePrevious(initial: Output) -> AnyPublisher<(old: Output, new: Output), Failure>
        where Output: Equatable
    {
        self
            .scan((initial, initial), { ($0.1, $1) })
            .filter { $0 != $1 }
            .eraseToAnyPublisher()
    }
}
