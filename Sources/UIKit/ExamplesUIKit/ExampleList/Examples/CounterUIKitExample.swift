import SwiftUI
import Combine
import ActomatonStore
import Counter
import ExampleListUIKit

public struct CounterUIKitExample: Example
{
    public init() {}

    public var exampleIcon: Image { Image(systemName: "goforward.plus") }

    @MainActor
    public func build() -> UIViewController
    {
        // NOTE: `Store` as a single-screen ViewModel.
        let store = Store(
            state: .init(),
            reducer: Counter.reducer,
            environment: ()
        )

        return CounterViewController(store: store)
    }
}

// MARK: - Private

@MainActor
private final class CounterViewController: UIViewController
{
    let _store: Store<Counter.Action, Counter.State>

    var store: Store<Counter.Action, Counter.State>.Proxy { _store.proxy }

    var cancellables: [AnyCancellable] = []

    init(store: Store<Counter.Action, Counter.State>)
    {
        self._store = store
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
                        store.send(.decrement)
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
                        store.send(.increment)
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
        self.view.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            hStack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            hStack.heightAnchor.constraint(equalToConstant: 100)
        ])

        // MARK: - Apply Binding

        self._store.$state
            .map { "\($0.count)" }
            .assign(to: \.text, on: countLabel)
            .store(in: &self.cancellables)
    }
}
