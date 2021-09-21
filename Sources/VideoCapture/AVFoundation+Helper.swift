import UIKit
import AVFoundation

public func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice?
{
    let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera],
        mediaType: .video,
        position: .unspecified
    )
    return discoverySession.devices.first { $0.position == position }
}

extension AVCaptureDevice.Position: CustomDebugStringConvertible
{
    public mutating func toggle()
    {
        switch self {
        case .front:
            self = .back
        default:
            self = .front
        }
    }

    public var debugDescription: String
    {
        switch self {
        case .front:
            return "front"
        case .back:
            return "back"
        case .unspecified:
            return "unspecified"
        @unknown default:
            return "unknown"
        }
    }
}

extension CGRect {
    public var percentDescription: String
    {
        "(x: \(percent(origin.x)), y: \(percent(origin.y)), w: \(percent(size.width)), h: \(percent(size.height)))"
    }
}

private func percent(_ x: CGFloat) -> String
{
    percentFormatter.string(from: NSNumber(value: Float(x))) ?? "NaN"
}

private let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.minimumIntegerDigits = 1
    formatter.maximumIntegerDigits = 3
    formatter.maximumFractionDigits = 0
    return formatter
}()
