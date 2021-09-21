import UIKit
import AVFoundation
import Vision
import Combine
import ActomatonStore
import VideoCapture

private enum Global
{
    private static let queuePrefix = "com.inamiy.Actomaton-Gallery.VideoDetector"
    static let textDetectionQueue = DispatchQueue(label: "\(queuePrefix).textDetectionQueue", qos: .userInteractive)
}

// MARK: - iOS Vision

/// Uses `VNDetectTextRectanglesRequest`.
func detectTextRects(
    cmSampleBuffer: CMSampleBuffer,
    deviceOrientation: UIDeviceOrientation
) -> AnyPublisher<[VNTextObservation], Swift.Error>
{
    Deferred { () -> AnyPublisher<[VNTextObservation], Swift.Error> in
        let passthrough = PassthroughSubject<[VNTextObservation], Swift.Error>()

        let request = VNDetectTextRectanglesRequest { request, error in
            if let error = error {
                passthrough.send(completion: .failure(error))
                return
            }

            if let results = request.results as? [VNTextObservation] {
                passthrough.send(results)
                passthrough.send(completion: .finished)
            }
        }
        request.reportCharacterBoxes = false

        let pixelBuffer = CMSampleBufferGetImageBuffer(cmSampleBuffer)!

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: deviceOrientation.estimatedImageOrientation?.cgImagePropertyOrientation ?? .up
        )

        // NOTE: Run async to return `passthrough` first.
        Global.textDetectionQueue.async {
            do {
                try handler.perform([request]) // synchronous
            }
            catch {
                passthrough.send(completion: .failure(error))
            }
        }

        return passthrough.eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/// Uses `VNRecognizeTextRequest`.
func detectTextRecognition(
    cmSampleBuffer: CMSampleBuffer,
    deviceOrientation: UIDeviceOrientation
) -> AnyPublisher<[VNRecognizedTextObservation], Swift.Error>
{
    Deferred { () -> AnyPublisher<[VNRecognizedTextObservation], Swift.Error> in
        let passthrough = PassthroughSubject<[VNRecognizedTextObservation], Swift.Error>()

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                passthrough.send(completion: .failure(error))
                return
            }

            if let results = request.results as? [VNRecognizedTextObservation] {
                passthrough.send(results)
                passthrough.send(completion: .finished)
            }
        }
        request.recognitionLevel = .fast

        let pixelBuffer = CMSampleBufferGetImageBuffer(cmSampleBuffer)!

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: deviceOrientation.estimatedImageOrientation?.cgImagePropertyOrientation ?? .up
        )

        // NOTE: Run async to return `passthrough` first.
        Global.textDetectionQueue.async {
            do {
                try handler.perform([request]) // synchronous
            }
            catch {
                passthrough.send(completion: .failure(error))
            }
        }

        return passthrough.eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

/// Uses `VNDetectFaceRectanglesRequest`.
func detectFaces(cmSampleBuffer: CMSampleBuffer, deviceOrientation: UIDeviceOrientation) -> AnyPublisher<[VNFaceObservation], Swift.Error>
{
    Deferred { () -> AnyPublisher<[VNFaceObservation], Swift.Error> in
        let passthrough = PassthroughSubject<[VNFaceObservation], Swift.Error>()

        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                passthrough.send(completion: .failure(error))
                return
            }

            if let results = request.results as? [VNFaceObservation] {
                passthrough.send(results)
                passthrough.send(completion: .finished)
            }
        }

        let pixelBuffer = CMSampleBufferGetImageBuffer(cmSampleBuffer)!

        // For `detectFaces`, orientation = `.up` will work for both portrait & landscape.
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: deviceOrientation.estimatedImageOrientation?.cgImagePropertyOrientation ?? .up,
            options: [:]
        )

        // NOTE: Run async to return `passthrough` first.
        Global.textDetectionQueue.async {
            do {
                try handler.perform([request]) // synchronous
            }
            catch {
                passthrough.send(completion: .failure(error))
            }
        }

        return passthrough.eraseToAnyPublisher()
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
}

// MARK: - VideoDetector.Error

extension VideoDetector
{
    public enum Error: Swift.Error
    {
        case detectionFailed
        case iOSVision(Swift.Error)
        case videoCapture(VideoCapture.Error)
    }
}

// MARK: - Vision boundingBox conversion

/// - Parameters:
///   - boundingBox: `CGRect` that has scale values from 0 to 1 in current device orientation's coordinate with bottom-left origin.
///   - deviceOrientation: Current device orientation.
/// - Returns: A new bounding box that has top-left origin in camera's coordinate, e.g. for passing to `AVCaptureVideoPreviewLayer.layerRectConverted`.
func convertBoundingBox(_ boundingBox: CGRect, deviceOrientation: UIDeviceOrientation) -> CGRect
{
    var boundingBox = boundingBox

    // Flip y-axis as `boundingBox.origin` starts from bottom-left.
    boundingBox.origin.y = 1 - boundingBox.origin.y - boundingBox.height

    switch deviceOrientation {
    case .portrait:
        // 90 deg clockwise
        boundingBox = boundingBox
            .applying(CGAffineTransform(translationX: -0.5, y: -0.5))
            .applying(CGAffineTransform(rotationAngle: -.pi / 2))
            .applying(CGAffineTransform(translationX: 0.5, y: 0.5))
    case .portraitUpsideDown:
        // 90 deg counter-clockwise
        boundingBox = boundingBox
            .applying(CGAffineTransform(translationX: -0.5, y: -0.5))
            .applying(CGAffineTransform(rotationAngle: .pi / 2))
            .applying(CGAffineTransform(translationX: 0.5, y: 0.5))
    case .landscapeLeft:
        break
    case .landscapeRight:
        // 180 deg
        boundingBox = boundingBox
            .applying(CGAffineTransform(translationX: -0.5, y: -0.5))
            .applying(CGAffineTransform(rotationAngle: .pi))
            .applying(CGAffineTransform(translationX: 0.5, y: 0.5))
    case .unknown,
         .faceUp,
         .faceDown:
        break
    @unknown default:
        break
    }

    return boundingBox
}
