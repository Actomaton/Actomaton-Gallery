import UIKit
import AVFoundation
import Combine
import ActomatonStore
import VideoCapture

/// VideoDetector namespace.
public enum VideoDetector {}

extension VideoDetector
{
    // MARK: - Action

    public enum Action: Sendable
    {
        case _didDetectRects([CGRect])
        case _didDetectTexts([CGRect], [String], [UIImage])
        case _error(Error)
        case videoCapture(VideoCapture.Action)
    }

    // MARK: - State

    public struct State: Equatable, Sendable
    {
        public var detectMode: DetectMode
        public var detectedRects: [CGRect]
        public var detectedTextImages: [UIImage]
        public var detectedTexts: [String]
        public var videoCapture: VideoCapture.State

        public init(
            detectMode: DetectMode = .textRect,
            detectedRects: [CGRect] = [],
            detectedTextImages: [UIImage] = [],
            detectedTexts: [String] = [],
            videoCapture: VideoCapture.State = .init(cameraPosition: .back)
        )
        {
            self.detectMode = detectMode
            self.detectedRects = detectedRects
            self.detectedTextImages = detectedTextImages
            self.detectedTexts = detectedTexts
            self.videoCapture = videoCapture
        }

        public enum DetectMode: Sendable
        {
            case face
            case textRect
            case textRecognitionIOSVision
        }
    }

    // MARK: - Environment

    public typealias Environment = ()

    // MARK: - Reducer

    public static var reducer: Reducer<Action, State, Environment>
    {
        return .combine(
            self._reducer,

            VideoCapture.reducer
                .contramap(action: /Action.videoCapture)
                .contramap(state: \.videoCapture)
        )
    }

    private static var _reducer: Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case let .videoCapture(._didOutput(cmSampleBuffer)):
                switch state.detectMode {
                case .face:
                    let publisher = detectFaces(
                        cmSampleBuffer: cmSampleBuffer,
                        deviceOrientation: state.videoCapture.deviceOrientation
                    )
                    .map { Action._didDetectRects($0.map { $0.boundingBox }) }
                    .catch { _ in Just(Action._error(.detectionFailed)) }
                    .eraseToAnyPublisher() // NOTE: For `@unchecked Sendable`

                    return publisher.toEffect()

                case .textRect:
                    let publisher = detectTextRects(
                        cmSampleBuffer: cmSampleBuffer,
                        deviceOrientation: state.videoCapture.deviceOrientation
                    )
                        .map { Action._didDetectRects($0.map { $0.boundingBox }) }
                        .catch { _ in Just(Action._error(.detectionFailed)) }
                        .eraseToAnyPublisher() // NOTE: For `@unchecked Sendable`

                    return publisher.toEffect()

                case .textRecognitionIOSVision:
                    let publisher = detectTextRecognition(
                        cmSampleBuffer: cmSampleBuffer,
                        deviceOrientation: state.videoCapture.deviceOrientation
                    )
                    .map {
                        Action._didDetectTexts(
                            $0.map { $0.boundingBox },
                            $0.flatMap { $0.topCandidates(3) }
                                .map { $0.string },
                            []
                        )
                    }
                    .catch { _ in Just(Action._error(.detectionFailed)) }
                    .eraseToAnyPublisher() // NOTE: For `@unchecked Sendable`

                    return publisher.toEffect()
                }

            case let ._didDetectRects(rects):
                state.detectedRects = rects
                    .map { convertBoundingBox($0, deviceOrientation: state.videoCapture.deviceOrientation) }
                state.detectedTexts = []
                state.detectedTextImages = []
                return .empty

            case let ._didDetectTexts(rects, texts, croppedImages):
                #if DEBUG
                if !rects.isEmpty {
                    print("===> _didDetectTexts = \(texts)")
                }
                #endif
                state.detectedRects = rects
                    .map { convertBoundingBox($0, deviceOrientation: state.videoCapture.deviceOrientation) }
                if !croppedImages.isEmpty {
                    state.detectedTextImages = croppedImages
                }
                state.detectedTexts = texts
                return .empty

            default:
                return .empty
            }
        }
    }
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension UIImage: @unchecked Sendable {}
