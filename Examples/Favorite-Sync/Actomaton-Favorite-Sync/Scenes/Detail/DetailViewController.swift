import UIKit
import Combine
import CombineCocoa
import ActomatonStore

final class DetailViewController: UIViewController
{
    private let store: Store<Action, State, Environment>

    private var cancellables: Set<AnyCancellable> = []

    init(store: Store<Action, State, Environment>)
    {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder)
    {
        fatalError()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        let imageView = UIImageView()

        let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 48)
            return titleLabel
        }()

        let favoriteButton: UIButton = {
            let favoriteButton = UIButton()
            favoriteButton.tintColor = .systemPink
            return favoriteButton
        }()

        let vStack: UIStackView = {
            let vStack = UIStackView(arrangedSubviews: [
                imageView,
                titleLabel,
                favoriteButton
            ])
            vStack.axis = .vertical
            vStack.alignment = .center
            vStack.distribution = .equalSpacing
            vStack.spacing = 16
            vStack.translatesAutoresizingMaskIntoConstraints = false
            return vStack
        }()

        self.view.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            vStack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ])

        self.store.$state
            .map {
                UIImage(
                    systemName: $0.card.symbol,
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 150)
                )
            }
            .removeDuplicates()
            .assign(to: \.image, on: imageView)
            .store(in: &self.cancellables)

        self.store.$state
            .map { $0.card.title }
            .removeDuplicates()
            .assign(to: \.text, on: titleLabel)
            .store(in: &self.cancellables)

        self.store.$state
            .map { $0.card.isFavorite }
            .removeDuplicates()
            .sink { isFavorite in
                favoriteButton.setImage(
                    UIImage(
                        systemName: isFavorite ? "heart.fill" : "heart",
                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 48)
                    ),
                    for: .normal
                )
            }
            .store(in: &self.cancellables)

        favoriteButton.tapPublisher
            .sink { [store] isFavorite in
                store.send(.didTapHeart)
            }
            .store(in: &self.cancellables)
    }

    typealias Action = Detail.Action
    typealias State = Detail.State
    typealias Environment = Detail.Environment
    typealias Route = Detail.Route
}
