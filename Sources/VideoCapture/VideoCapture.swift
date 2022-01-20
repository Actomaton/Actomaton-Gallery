import UIKit
import AVFoundation
import Combine
import ActomatonStore

/// VideoCapture namespace.
public enum VideoCapture {}

extension VideoCapture
{
    // MARK: - Action

    public enum Action: Sendable
    {
        case makeSession
        case _didMakeSession(SessionID)
        case startSession
        case _didOutput(CMSampleBuffer)
        case _didUpdateOrientation(UIDeviceOrientation)
        case changeCameraPosition
        case stopSession
        case _didStopSession
        case _error(Error)
        case removeSession
    }

    // MARK: - State

    public struct State: Equatable, Sendable
    {
        var cameraPosition: AVCaptureDevice.Position
        public var sessionState: SessionState

        public var deviceOrientation: UIDeviceOrientation

        public init(
            cameraPosition: AVCaptureDevice.Position = .front,
            sessionState: SessionState = .noSession,
            deviceOrientation: UIDeviceOrientation = .unknown
        )
        {
            self.cameraPosition = cameraPosition
            self.sessionState = sessionState
            self.deviceOrientation = deviceOrientation
        }

        public enum SessionState: Equatable, Sendable, CustomStringConvertible
        {
            case noSession
            case idle(SessionID)
            case running(SessionID)

            public var sessionID: SessionID?
            {
                switch self {
                case .noSession:
                    return nil
                case let .idle(sessionID),
                     let .running(sessionID):
                    return sessionID
                }
            }

            public var description: String
            {
                switch self {
                case .noSession:
                    return "noSession"
                case .idle:
                    return "idle"
                case .running:
                    return "running"
                }
            }
        }
    }

    // MARK: - Environment

    public typealias Environment = ()

    // MARK: - EffectID

    public struct OrientationEffectID: EffectIDProtocol {}

    // MARK: - Reducer

    public static var reducer: Reducer<Action, State, Environment>
    {
        .init { action, state, environment in
            switch action {
            case .makeSession:
                let publisher = makeSession(cameraPosition: state.cameraPosition)
                    .map(Action._didMakeSession)
                    .catch { Just(Action._error($0)) }
                return publisher.toEffect()

            case let ._didMakeSession(sessionID):
                state.sessionState = .idle(sessionID)
                return Effect.nextAction(.startSession)

            case .startSession:
                guard case let .idle(sessionID) = state.sessionState else {
                    return .empty
                }

                state.sessionState = .running(sessionID)

                let sessionPublisher = startSession(sessionID: sessionID)
                    .map(Action._didOutput)
                    .catch { Just(Action._error($0))}

                let orientationPublisher = startOrientation(interval: 0.1)
                    .map(Action._didUpdateOrientation)

                return sessionPublisher.toEffect()
                    + orientationPublisher.toEffect(id: OrientationEffectID())

            case ._didOutput:
                // Ignored: Composing reducer should handle this.
                return .empty

            case let ._didUpdateOrientation(deviceOrientation):
                state.deviceOrientation = deviceOrientation
                return .empty

            case .changeCameraPosition:
                guard let sessionID = state.sessionState.sessionID else {
                    return .empty
                }
                state.cameraPosition.toggle()

                let publisher = setupCaptureSessionInput(
                    sessionID: sessionID,
                    cameraPosition: state.cameraPosition
                )
                .compactMap { _ in nil }
                .catch { Just(Action._error($0))}

                return publisher.toEffect()

            case .stopSession:
                guard case let .running(sessionID) = state.sessionState else {
                    return .empty
                }

                let publisher = stopSession(sessionID: sessionID)
                    .map { _ in Action._didStopSession }
                    .catch { Just(Action._error($0))}
                return publisher.toEffect()

            case ._didStopSession:
                guard case let .running(sessionID) = state.sessionState else {
                    return .empty
                }
                state.sessionState = .idle(sessionID)
                return .cancel(id: OrientationEffectID())

            case let ._error(error):
                let publisher = log("\(error)")
                    .flatMap { Empty<Action, Never>(completeImmediately: true) }
                return publisher.toEffect()

            case .removeSession:
                if case .noSession = state.sessionState {
                    return .empty
                }
                state.sessionState = .noSession

                let publisher = removeSession()
                    .flatMap { Empty<Action, Never>(completeImmediately: true) }
                return publisher.toEffect()
            }
        }
    }
}

// MARK: - Enum Properties

extension VideoCapture.State.SessionState
{
    public var isRunning: Bool
    {
        guard case .running = self else { return false }
        return true
    }
}

// MARK: - @unchecked Sendable

// TODO: Remove `@unchecked Sendable` when `Sendable` is supported by each module.
extension CMSampleBuffer: @unchecked Sendable {}
