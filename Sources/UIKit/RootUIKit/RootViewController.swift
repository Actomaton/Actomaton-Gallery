import UIKit
import SwiftUI
import Combine
import ActomatonStore
import UserSession
import Onboarding
import Login
import TabUIKit
import SettingsUIKit

@MainActor
public final class RootViewController: UIViewController
{
    private let store: Store<Action, State>
    private var cancellables: [AnyCancellable] = []

    private var currentViewController: UIViewController?
    {
        willSet {
            if let currentViewController = currentViewController {
                if let newVC = newValue {
                    self.remove(child: currentViewController)
                    self.add(child: newVC)
                }
                else {
                    self.remove(child: currentViewController)
                }
            }
            else {
                if let newVC = newValue {
                    self.add(child: newVC)
                }
                else {
                    assertionFailure("Should not reach here.")
                }
            }
        }
    }

    public init(store: Store<Action, State>)
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

        /// Workaround for `removeDuplicates`.
        struct Pair<X, Y>: Equatable where X: Equatable, Y: Equatable
        {
            var x: X
            var y: Y
        }

        // Main presentation.
        self.store.$state
            .map { state in Pair(x: state.isOnboardingComplete, y: state.userSession.authStatus) }
            //.removeDuplicates(by: { $0.0 == $1.0 && $0.1 == $1.1 }) // Comment-Out: Compiles forever
            .removeDuplicates()
            // Workaround:
            // Since `Published.Publisher` emits values on `willSet` by design,
            // to reference `store`'s latest state, minimum delay (`receive(on:)`) is required.
            // https://forums.swift.org/t/is-this-a-bug-in-published/31292/39
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pair in
                guard let self = self else { return }

                let isOnboardingComplete = pair.x
                let authStatus = pair.y

                if isOnboardingComplete {
                    self.onStateAfterOnboarding(authStatus: authStatus)
                }
                else {
                    self.onStateBeforeOnboarding()
                }
            }
            .store(in: &self.cancellables)

        // Error alert.
        self.store.$state
            .map { $0.userSession.error }
            .removeDuplicates()
            .sink { [weak self] error in
                guard let self = self, let error = error else { return }

                let alert = AlertBuilder.build(
                    title: "Force Logout",
                    message: error.localizedDescription,
                    actions: [
                        UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.store.proxy.send(Action.userSession(.forceLogout))
                        })
                    ]
                )
                self.present(alert, animated: true, completion: nil)
            }
            .store(in: &self.cancellables)

        // Setup empty VC for delay workaround.
        self.currentViewController = {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 246/255, alpha: 1)
            return vc
        }()
    }

    private func onStateAfterOnboarding(authStatus: UserSession.State.AuthStatus)
    {
        switch authStatus {
        case .loggedOut:
            let vc = UIHostingController(
                rootView: LoginView(onAction: { [store] in
                    store.proxy.send(Action.loggedOut($0))
                })
            )
            self.currentViewController = vc

        case .loggedIn:
            let substore = store.observableProxy
                .contramap(action: Action.tab)
                .map { $0.tab }

            let vc = TabBuilder.build(store: substore)
            self.currentViewController = vc

        case .loggingIn:
            let vc = UIHostingController(
                rootView: VStack(spacing: 16) {
                    ProgressView()
                    Text("Logging in...")
                }
            )
            self.currentViewController = vc

        case .loggingOut:
            let vc = UIHostingController(
                rootView: VStack(spacing: 16) {
                    ProgressView()
                    Text("Logging out...")
                }
            )
            self.currentViewController = vc
        }
    }

    private func onStateBeforeOnboarding()
    {
        let vc = HostingViewController(
            store: self.store.observableProxy,
            makeView: { store in
                OnboardingView(
                    isOnboardingComplete: store.isOnboardingComplete
                        .stateBinding(onChange: { $0 ? .didFinishOnboarding : nil })
                )
            }
        )
        self.currentViewController = vc
    }
}

// MARK: - add/remove

extension RootViewController
{
    fileprivate func add(
        child: UIViewController,
        layout: (_ parent: UIViewController, _ child: UIViewController) -> () = { _, _ in }
    )
    {
        self.addChild(child)
        self.view.addSubview(child.view)
        child.didMove(toParent: self)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    fileprivate func remove(child: UIViewController)
    {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
