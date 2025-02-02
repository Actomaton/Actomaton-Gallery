import UIKit
import AVFoundation
import Vision
import Combine
import ActomatonUI
import OrientationKit

// FIXME: This entire effectful code needs to be refactored to avoid using global variables and make Sendable-friendly.

// MARK: -  Global states

@MainActor
internal enum Global
{
    // TODO: Not meaningful to manage references by dictionary at the moment.
    static var videoSessions: [SessionID: AVCaptureSession] = [:]
    static var videoOutputs: [SessionID: AVCaptureVideoDataOutput] = [:]
    static var videoOutputHandlers: [SessionID: VideoOutputHandler] = [:]

    static var currentVideoSessionID = SessionID(value: 0)

    private static let queuePrefix = "com.inamiy.Actomaton-Gallery.VideoCapture"
    static let sessionQueue = DispatchQueue(label: "\(queuePrefix).sessionQueue")
    static let videoOutputQueue = DispatchQueue(label: "\(queuePrefix).videoDataOutputQueue", qos: .userInteractive)
    static let textDetectionQueue = DispatchQueue(label: "\(queuePrefix).textDetectionQueue", qos: .userInteractive)

    static let orientationManager = OrientationManager()
}

// MARK: - CaptureSession

@MainActor
func makeSessionID() -> SessionID
{
    Global.currentVideoSessionID.increment()
    return Global.currentVideoSessionID
}

@MainActor
func removeSession() -> AnyPublisher<Void, Never>
{
    Deferred { () -> Just<Void> in
        for (_, session) in Global.videoSessions {
            if session.isRunning {
                session.stopRunning()
            }

            session.beginConfiguration()
            defer { session.commitConfiguration() }

            for input in session.inputs {
                session.removeInput(input)
            }
            for output in session.outputs {
                session.removeOutput(output)
            }
        }
        Global.videoSessions = [:]
        Global.videoOutputs = [:]
        Global.videoOutputHandlers = [:]

        return Just(())
    }
    .subscribe(on: Global.sessionQueue)
    .eraseToAnyPublisher()
}

@MainActor
func makeSession(cameraPosition: AVCaptureDevice.Position) -> AnyPublisher<SessionID, VideoCapture.Error>
{
    Deferred { () -> AnyPublisher<SessionID, VideoCapture.Error> in
        let sessionID = makeSessionID()
        let captureSession = AVCaptureSession()

        Global.videoSessions[sessionID] = captureSession

        let setUpInput = setupCaptureSessionInput(sessionID: sessionID, cameraPosition: cameraPosition)
        let setUpOutput = setupCaptureSessionOutput(sessionID: sessionID)

        return setUpInput
            .flatMap { () in setUpOutput }
            .flatMap { () -> Result<SessionID, VideoCapture.Error>.Publisher in
                .init(sessionID)
            }
            .eraseToAnyPublisher()
    }
    .subscribe(on: Global.sessionQueue)
    .eraseToAnyPublisher()
}

@MainActor
func setupCaptureSessionInput(
    sessionID: SessionID,
    cameraPosition: AVCaptureDevice.Position
) -> AnyPublisher<Void, VideoCapture.Error>
{
    Deferred {
        Future<Void, VideoCapture.Error> { handler in
            guard let captureSession = Global.videoSessions[sessionID] else {
                return handler(.failure(.videoSessionNotExisting(sessionID)))
            }
            guard let device = captureDevice(forPosition: cameraPosition) else {
                return handler(.failure(.captureDeviceNotAvailable(cameraPosition: cameraPosition)))
            }

            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }

            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }

            let input_ = try? AVCaptureDeviceInput(device: device)

            guard let input = input_, captureSession.canAddInput(input) else {
                return handler(.failure(.deviceInputNotAvailable))
            }
            captureSession.addInput(input)

            handler(.success(()))
        }
    }
    .subscribe(on: Global.sessionQueue)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

@MainActor
func setupCaptureSessionOutput(sessionID: SessionID) -> AnyPublisher<Void, VideoCapture.Error>
{
    Deferred {
        Future<Void, VideoCapture.Error> { handler in
            guard let captureSession = Global.videoSessions[sessionID] else {
                return handler(.failure(.videoSessionNotExisting(sessionID)))
            }

            captureSession.beginConfiguration()
            defer { captureSession.commitConfiguration() }

            captureSession.sessionPreset = .inputPriority

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA,
            ]
            output.alwaysDiscardsLateVideoFrames = true

            guard captureSession.canAddOutput(output) else {
                return handler(.failure(.deviceOutputNotAvailable))
            }

            captureSession.addOutput(output)

            Global.videoOutputs[sessionID] = output

            handler(.success(()))
        }
    }
    .subscribe(on: Global.sessionQueue)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

@MainActor
func startSession(sessionID: SessionID) -> AnyPublisher<CMSampleBuffer, VideoCapture.Error>
{
    Deferred { () -> AnyPublisher<CMSampleBuffer, VideoCapture.Error> in
        guard let captureSession = Global.videoSessions[sessionID],
              let output = Global.videoOutputs[sessionID] else
        {
            return Fail(outputType: CMSampleBuffer.self, failure: .videoSessionNotExisting(sessionID))
                .eraseToAnyPublisher()
        }

        guard !captureSession.isRunning else {
            return Fail(outputType: CMSampleBuffer.self, failure: .videoSessionAlreadyRunning(sessionID))
                .eraseToAnyPublisher()
        }

        let passthrough = PassthroughSubject<CMSampleBuffer, VideoCapture.Error>()

        let outputHandler = VideoOutputHandler { params in
            passthrough.send(params)
        }
        Global.videoOutputHandlers[sessionID] = outputHandler

        output.setSampleBufferDelegate(outputHandler.delegate, queue: Global.videoOutputQueue)

        if !captureSession.isRunning {
            captureSession.startRunning()
        }

        return passthrough.eraseToAnyPublisher()
    }
    .subscribe(on: Global.sessionQueue)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

@MainActor
func stopSession(sessionID: SessionID) -> AnyPublisher<Void, VideoCapture.Error>
{
    Deferred { () -> AnyPublisher<Void, VideoCapture.Error> in
        guard let captureSession = Global.videoSessions[sessionID],
              let output = Global.videoOutputs[sessionID] else
        {
            return Fail(outputType: Void.self, failure: .videoSessionNotExisting(sessionID))
                .eraseToAnyPublisher()
        }

        guard captureSession.isRunning else {
            return Fail(outputType: Void.self, failure: .videoSessionNotRunning(sessionID))
                .eraseToAnyPublisher()
        }

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        Global.videoOutputHandlers.removeValue(forKey: sessionID)
        output.setSampleBufferDelegate(nil, queue: nil)

        return Result.Publisher(.success(())).eraseToAnyPublisher()
    }
    .subscribe(on: Global.sessionQueue)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

func log(_ items: Any...) -> AnyPublisher<Void, Never>
{
    #if DEBUG
    return Deferred { () -> Just<Void> in
        print(items)
        return Just(())
    }
    .eraseToAnyPublisher()
    #else
    return Just(())
        .eraseToAnyPublisher()
    #endif
}

// MARK: - OrientationManager

@MainActor
func startOrientation(interval: TimeInterval, queue: OperationQueue = .current ?? .main) -> AnyPublisher<UIDeviceOrientation, Never>
{
    Deferred { () -> AnyPublisher<UIDeviceOrientation, Never> in
        Global.orientationManager.start(interval: interval, queue: queue)

        return Global.orientationManager.$deviceOrientation
            .filter { !$0.isFlat }
            .eraseToAnyPublisher()
    }
    .handleEvents(receiveCancel: {
        Global.orientationManager.stop()
    })
//    .handleEvents(receiveOutput: {
//        print("deviceOrientation = \($0)")
//    })
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

// MARK: - VideoCapture.Error

extension VideoCapture
{
    public enum Error: Swift.Error
    {
        case videoSessionNotExisting(SessionID)
        case videoSessionAlreadyRunning(SessionID)
        case videoSessionNotRunning(SessionID)
        case captureDeviceNotAvailable(cameraPosition: AVCaptureDevice.Position)
        case deviceInputNotAvailable
        case deviceOutputNotAvailable
    }
}
