import SwiftUI
@preconcurrency import AVFoundation

#if (os(iOS) || os(tvOS))
import UIKit

public struct VideoPreviewView: UIViewRepresentable
{
    private let session: AVCaptureSession
    private let detectedRects: [CGRect]

    /// - Parameters:
    ///   - detectedRects: Must have `(0,0)` at top-left in camera's coordinate (`UIDeviceOrientation.left`)
    public init?(
        sessionID: SessionID,
        detectedRects: [CGRect] = []
    )
    {
        guard let session = Global.videoSessions[sessionID] else {
            return nil
        }

        self.session = session
        self.detectedRects = detectedRects
    }

    public func makeUIView(context: Context) -> UIKitView
    {
        return UIKitView(session: self.session)
    }

    public func updateUIView(_ uiView: UIKitView, context: Context)
    {
        uiView.update(detectedRects: self.detectedRects)
    }
}

// MARK: - Internal UIKitView

extension VideoPreviewView
{
    public class UIKitView: UIView
    {
        let previewLayer: AVCaptureVideoPreviewLayer
        let detectedLayers: [CALayer]

        private let rotationCoordinator: AVCaptureDevice.RotationCoordinator?
        private let rotationObservation: NSKeyValueObservation?

        public init(session: AVCaptureSession)
        {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            self.previewLayer = previewLayer
            self.previewLayer.contentsGravity = .resizeAspectFill
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.backgroundColor = UIColor.black.cgColor

            func makeDetectedLayer() -> CALayer
            {
                let layer = CALayer()
                layer.borderColor = UIColor.green.cgColor
                layer.borderWidth = 4
                layer.isHidden = true
                previewLayer.addSublayer(layer)
                return layer
            }

            self.detectedLayers = (1...100).map { _ in makeDetectedLayer() }

            let device = session.inputs
                .compactMap { $0 as? AVCaptureDeviceInput }
                .first?
                .device

            if let device {
                let coordinator = AVCaptureDevice.RotationCoordinator(
                    device: device,
                    previewLayer: previewLayer
                )
                self.rotationCoordinator = coordinator

                // Workaround to suppress warning:
                // "Capture of 'previewLayer' with non-Sendable type 'AVCaptureVideoPreviewLayer' in a '@Sendable' closure"
                nonisolated(unsafe) let unsafePreviewLayer = previewLayer

                self.rotationObservation = coordinator.observe(
                    \.videoRotationAngleForHorizonLevelPreview,
                    options: [.initial, .new]
                ) { coordinator, _ in
                    unsafePreviewLayer.connection?.videoRotationAngle = coordinator.videoRotationAngleForHorizonLevelPreview
                }
            }
            else {
                self.rotationCoordinator = nil
                self.rotationObservation = nil
            }

            super.init(frame: .zero)

            self.layer.addSublayer(self.previewLayer)
        }

        required init?(coder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }

        public override func layoutSubviews()
        {
            super.layoutSubviews()
            self.previewLayer.frame = self.layer.bounds
        }

        func update(detectedRects: [CGRect])
        {
            // Required for avoiding `CALayer position contains NaN: [nan nan]` crash
            // when session is deallocated.
            guard self.previewLayer.session?.isRunning == true else {
                return
            }

            CATransaction.setDisableActions(true)
            defer { CATransaction.setDisableActions(false) }

            self.detectedLayers.forEach {
                $0.isHidden = true
            }

//            print("detectedRects = \(detectedRects.max(by: { $0.width * $0.height < $1.width * $1.height })?.percentDescription ?? "none")")

            zip(detectedRects, self.detectedLayers).forEach { rect, layer in
                // NOTE:
                // `metadataOutputRect` must have `(0,0)` at top-left in camera's coordinate (`UIDeviceOrientation.left`),
                // which will be converted into current device orientation's coordinate.
                let convertedRect = self.previewLayer.layerRectConverted(fromMetadataOutputRect: rect)

                layer.frame = convertedRect
                layer.isHidden = false

                self.previewLayer.addSublayer(layer)
            }
        }
    }
}
#endif
