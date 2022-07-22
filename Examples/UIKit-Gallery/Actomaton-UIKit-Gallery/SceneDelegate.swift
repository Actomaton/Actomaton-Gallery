import UIKit
import SwiftUI
import Combine
import ActomatonUI
import RootUIKit

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        let tabC = RootBuilder.build(
            environment: .init(window: window)
        )
        window.rootViewController = tabC
        self.window = window
        window.makeKeyAndVisible()
    }
}

