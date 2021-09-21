import UIKit
import SwiftUI
import Combine
import ActomatonStore

@MainActor
class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabC = TabBuilder.build()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabC
        self.window = window
        window.makeKeyAndVisible()
    }
}

