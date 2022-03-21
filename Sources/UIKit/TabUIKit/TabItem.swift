import UIKit
import SwiftUI
import ActomatonStore
import ExampleListUIKit

public struct TabItem<ID>: Equatable, Sendable
    where ID: Equatable & Sendable
{
    public var id: ID
    public var title: String
    public var tabBarItem: UITabBarItem
    public var build: @Sendable @MainActor () -> UIViewController

    public init(
        id: ID,
        title: String,
        tabBarItem: UITabBarItem,
        build: @Sendable @escaping @MainActor () -> UIViewController
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = tabBarItem
        self.build = build
    }

    public static func == (l: Self, r: Self) -> Bool
    {
        l.id == r.id
    }
}

extension TabItem
{
    /// Initializes with `image`.
    public init(
        id: ID,
        title: String,
        image: UIImage,
        build: @Sendable @escaping @MainActor () -> UIViewController
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.build = build
    }

    /// Initializes with `examples`.
    public init(
        id: ID,
        title: String,
        image: UIImage,
        examples: [Example]
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.build = { @MainActor in
            ExampleListBuilder.build(examples: examples)
        }
    }

    /// Initializes with `Store` and `SwiftUI.View`.
    public init<Action, State, V: View>(
        id: ID,
        title: String,
        image: UIImage,
        store: Store<Action, State, Environment>,
        view: @escaping (Store<Action, State, Void>.Proxy) -> V
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.build = { @MainActor in
            HostingViewController(store: store, makeView: view)
        }
    }

    /// Initializes with `Store.ObservableProxy` and `SwiftUI.View`.
    public init<Action, State, V: View>(
        id: ID,
        title: String,
        image: UIImage,
        store: Store<Action, State, Environment>.ObservableProxy,
        view: @escaping (Store<Action, State, Void>.Proxy) -> V
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.build = { @MainActor in
            HostingViewController(store: store, makeView: view)
        }
    }

    /// Initializes with `SwiftUI.View`.
    public init<V: View>(
        id: ID,
        title: String,
        image: UIImage,
        view: @escaping () -> V
    )
    {
        self.id = id
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.build = { @MainActor in
            UIHostingController(rootView: view())
        }
    }
}

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.

extension UITabBarItem: @unchecked Sendable {}
