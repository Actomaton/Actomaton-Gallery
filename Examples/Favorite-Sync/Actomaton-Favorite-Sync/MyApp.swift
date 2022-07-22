import SwiftUI
import UIKit
import ActomatonUI

@MainActor
@main
struct MyApp: App
{
    @State
    private var usesUIKit: Bool = true

    var body: some Scene
    {
        WindowGroup {
            ZStack(alignment: .bottomTrailing) {
                // NOTE:
                // Not same as `tabView(usesUIKit: usesUIKit)` because `usesUIKit` is used as UIKit parameter.
                if usesUIKit {
                    tabView(usesUIKit: true)
                }
                else {
                    tabView(usesUIKit: false)
                }

                toggleView
            }
        }
    }

    private func tabView(usesUIKit: Bool) -> some View
    {
        uiViewControllerToSwiftUI {
            let environment = CardList._Environment.live

            let childVCs: [UIViewController] = [
                HomeBuilder.buildNavigation(environment: environment, usesUIKit: usesUIKit),
                FavoriteBuilder.buildNavigation(environment: environment, usesUIKit: usesUIKit)
            ]

            let tabC = UITabBarController()
            tabC.setViewControllers(childVCs, animated: false)
            return tabC
        }
        .ignoresSafeArea()
    }

    private var toggleView: some View
    {
        Toggle(isOn: $usesUIKit) {
            Image(systemName: "ladybug")
            Text("Use UIKit")
        }
        .frame(width: 200)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(Color.white.opacity(0.75))
                .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
        )
        .offset(x: -8, y: -50)
    }
}
