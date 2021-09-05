import UIKit
import Combine
import ActomatonStore

/// Simple image loader for Actomaton Architecture.
enum ImageLoader {}

extension ImageLoader
{
    enum Action
    {
        case requestImage(url: URL)
        case _cacheImage(url: URL, image: UIImage)
        case cancelRequest(url: URL)
        case removeImage(url: URL)
    }

    struct State: Equatable
    {
        var images: [URL: UIImage] = [:]
        var isRequesting: [URL: Bool] = [:]
    }

    static var reducer: Reducer<Action, State, Environment>
    {
        .init { action, state, environment in

            switch action {
            case let .requestImage(url):
                // Skip if there is already cached image.
                if state.images[url] != nil { return .empty }

                if !state.isRequesting[url, default: false] {
                    state.isRequesting[url] = true

                    // Fetch & cache image.
                    let effect: Effect<Action> =
                        self.fetchImage(request: Request(url: url), environment: environment)
                        .compactMap { $0.map { Action._cacheImage(url: url, image: $0.image) } }
                        .toEffect(id: ImageURLEffectID(url: url))

                    return effect
                }
                else {
                    return .empty
                }

            case let ._cacheImage(url, image):
                state.isRequesting[url] = false
                state.images[url] = image

            case let .cancelRequest(url):
                state.isRequesting[url] = false
                return Effect.cancel(id: ImageURLEffectID(url: url))

            case let .removeImage(url):
                state.images[url] = .none
            }

            return .empty
        }
    }

    struct ImageURLEffectID: EffectIDProtocol {
        let url: URL
    }

    struct Environment
    {
        let urlSession: URLSession
    }
}

extension ImageLoader
{
    public struct Request
    {
        public let url: URL
    }

    public struct Response
    {
        public let image: UIImage
    }

    public static func fetchImage(
        request: Request,
        environment: Environment
    ) -> AnyPublisher<Response?, Never>
    {
        print("===> fetchImage = \(request.url)")

        let urlRequest = URLRequest(url: request.url)
        return environment.urlSession.dataTaskPublisher(for: urlRequest)
            .map { UIImage(data: $0.data).map { Response(image: $0) } }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
