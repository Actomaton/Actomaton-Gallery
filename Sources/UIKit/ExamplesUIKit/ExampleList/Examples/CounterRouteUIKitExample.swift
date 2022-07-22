import SwiftUI
import Combine
import ActomatonUI
import Counter
import ExampleListUIKit

public struct CounterRouteUIKitExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "goforward.plus") }

    @MainActor
    public func build() -> UIViewController
    {
        // NOTE: `Store` as a single-screen ViewModel.
        let store = RouteStore(
            state: Counter.State(),
            reducer: Reducer<Action, Counter.State, Environment> { action, state, env in
                switch action {
                case .popNavigation:
                    return Effect.fireAndForget {
                        env.sendRoute(.popNavigation)
                    }

                case .changeTab:
                    return Effect.fireAndForget {
                        env.sendRoute(.changeTab)
                    }

                case .action:
                    return Counter.reducer
                        .contramap(action: /Action.action)
                        .contramap { $0.environment }
                        .run(action, &state, env)
                }
            },
            environment: (),
            routeType: Route.self
        )

        let vc = CounterRouteViewController(store: store.noEnvironment)

        // WARNING:
        // These routings are just for simple demo,
        // and more global router should be passed in and called here.
        //
        // In general, accessing to `vc.navigationController` / `vc.tabBarController` is not recommended.
        store.subscribeRoutes { [weak vc] route in
            switch route {
            case .popNavigation:
                vc?.navigationController?.popViewController(animated: true)

            case .changeTab:
                vc?.tabBarController?.selectedIndex = 1
            }
        }

        return vc
    }
}

// MARK: - Private

private enum Action
{
    case popNavigation
    case changeTab
    case action(Counter.Action)
}

private enum Route
{
    case popNavigation
    case changeTab
}

private typealias Environment = SendRouteEnvironment<Counter.Environment, Route>

@MainActor
private final class CounterRouteViewController: UIViewController
{
    let store: Store<Action, Counter.State, Void>

    var cancellables: [AnyCancellable] = []

    init(store: Store<Action, Counter.State, Void>)
    {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // MARK: - Apply UI

        self.view.backgroundColor = .white

        let countLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 48)
            label.textAlignment = .center
            label.setContentCompressionResistancePriority(.required, for: .horizontal)

            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 100)
            ])
            return label
        }()

        let decrementButton: UIButton = {
            let config = UIImage.SymbolConfiguration(pointSize: 48)

            let button = UIButton(
                primaryAction: .init(
                    title: "",
                    image: UIImage(systemName: "minus.circle", withConfiguration: config),
                    attributes: [],
                    state: .off,
                    handler: { [store] action in
                        store.send(.action(.decrement))
                    }
                )
            )
            return button
        }()

        let incrementButton: UIButton = {
            let config = UIImage.SymbolConfiguration(pointSize: 48)

            let button = UIButton(
                primaryAction: .init(
                    title: "",
                    image: UIImage(systemName: "plus.circle", withConfiguration: config),
                    attributes: [],
                    state: .off,
                    handler: { [store] action in
                        store.send(.action(.increment))
                    }
                )
            )
            return button
        }()

        let hStack: UIStackView = {
            let stack = UIStackView(
                arrangedSubviews: [
                    decrementButton,
                    countLabel,
                    incrementButton
                ]
            )
            stack.axis = .horizontal
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()

        let popButton: UIButton = {
            let button = UIButton(
                primaryAction: .init(
                    title: "Pop Navigation",
                    attributes: [],
                    state: .off,
                    handler: { [store] action in
                        store.send(.popNavigation)
                    }
                )
            )
            button.titleLabel?.font = .systemFont(ofSize: 28)

            return button
        }()

        let changeTabButton: UIButton = {
            let button = UIButton(
                primaryAction: .init(
                    title: "Change Tab",
                    attributes: [],
                    state: .off,
                    handler: { [store] action in
                        store.send(.changeTab)
                    }
                )
            )
            button.titleLabel?.font = .systemFont(ofSize: 28)

            return button
        }()

        let vStack: UIStackView = {
            let stack = UIStackView(
                arrangedSubviews: [
                    hStack,
                    popButton,
                    changeTabButton
                ]
            )
            stack.axis = .vertical
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        self.view.addSubview(vStack)

        NSLayoutConstraint.activate([
            hStack.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            hStack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            hStack.heightAnchor.constraint(equalToConstant: 100)
        ])

        // MARK: - Apply Binding

        self.store.$state
            .map { "\($0.count)" }
            .assign(to: \.text, on: countLabel)
            .store(in: &self.cancellables)
    }
}
