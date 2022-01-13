import UIKit
import Combine
import CombineCocoa
import ActomatonStore

final class CardListViewController: UIViewController
{
    private let store: Store<Action, State>

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private var cancellables: Set<AnyCancellable> = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.clipsToBounds = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        self.dataSource = makeDataSource(
            collectionView: collectionView,
            store: self.store
        )
        collectionView.dataSource = dataSource

        return collectionView
    }()

    let emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "No Cards"
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 48)
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        return emptyLabel
    }()

    init(store: Store<Action, State>)
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

        self.view.addSubview(collectionView)
        self.view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            emptyLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])

        self.store.$state
            .map { $0.cards }
            .sink { [weak self] cards in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(cards.map(Item.init))
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &self.cancellables)

        self.store.$state
            .map { $0.shouldShowEmptyView }
            .removeDuplicates()
            .sink { [weak self] shouldShowEmptyView in
                guard let self = self else { return }
                self.emptyLabel.isHidden = !shouldShowEmptyView
            }
            .store(in: &self.cancellables)

        self.store.$state
            .map { $0.loadingState }
            .removeDuplicates()
            .sink { loadingState in
                let (isLoading, errorString) = loadingState.values

                // TODO: Use UI.
                print("===> isLoading = \(isLoading), errorString = \(errorString ?? "")")
            }
            .store(in: &self.cancellables)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.store.send(.loadFavorites)
        self.store.send(.fetchCards)
    }

    typealias Action = CardList.Action
    typealias State = CardList.State
    typealias Route = CardList.Route
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CardListViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let card = self.store.state.cards[indexPath.item]
        self.store.send(.didTapCard(card))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize
    {
        return CGSize(width: 150, height: 150)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets
    {
        .init(top: 0, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat
    {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat
    {
        16
    }
}

// MARK: - DiffableDataSource

private enum Section
{
    case main
}

private struct Item: Hashable
{
    let card: CardWithFavorite
}

private func makeDataSource(
    collectionView: UICollectionView,
    store: Store<CardList.Action, CardList.State>
) -> UICollectionViewDiffableDataSource<Section, Item>
{
    let cellRegistration = UICollectionView.CellRegistration<CardListCell, Item>() { cell, indexPath, item in
        let color = colors[indexPath.item % colors.count]

        cell.backgroundColor = color
        cell.layer.cornerRadius = 16

        cell.imageView.image = UIImage(
            systemName: item.card.symbol,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 64)
        )

        cell.titleLabel.text = item.card.title

        cell.favoriteButton.setImage(
            UIImage(
                systemName: item.card.isFavorite ? "heart.fill" : "heart",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)
            ),
            for: .normal
        )

        cell.favoriteButton.tapPublisher
            .sink { [weak store] _ in
                store?.send(.didTapHeart(item.card.id))
            }
            .store(in: &cell.cancellables)
    }

    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
        collectionView: collectionView
    ) { collectionView, indexPath, item -> UICollectionViewCell? in
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }

    return dataSource
}

// MARK: - CardListCell

class CardListCell: UICollectionViewCell
{
    let imageView = UIImageView()

    var cancellables: Set<AnyCancellable> = []

    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()

    let favoriteButton: UIButton = {
        let favoriteButton = UIButton()
        favoriteButton.tintColor = .systemPink
        return favoriteButton
    }()

    private(set) lazy var vStack: UIStackView = {
        let vStack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            favoriteButton
        ])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.distribution = .equalSpacing
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()

    override init(frame: CGRect)
    {
        super.init(frame: frame)

        self.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            vStack.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse()
    {
        self.cancellables = []
        super.prepareForReuse()
    }

    static let cellIdentifier = "CardListCell"
}

// MARK: - Private

private let colors: [UIColor] = [.systemYellow, .systemPurple, .systemGreen]
