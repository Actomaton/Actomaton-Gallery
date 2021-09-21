import UIKit
import AVFoundation

func withSampleBuffer(sampleBuffer: CMSampleBuffer, transform: (CVPixelBuffer) -> CVPixelBuffer?) -> CMSampleBuffer?
{
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
        return nil
    }

    guard let newPixelBuffer = transform(pixelBuffer),
          let formatDescription = CMFormatDescription.make(from: newPixelBuffer),
          var timingInfo = CMSampleTimingInfo.make(from: newPixelBuffer) else
    {
        return nil
    }

    var sampleBuffer: CMSampleBuffer?

    CMSampleBufferCreateForImageBuffer(
        allocator: kCFAllocatorDefault,
        imageBuffer: newPixelBuffer,
        dataReady: true,
        makeDataReadyCallback: nil,
        refcon: nil,
        formatDescription: formatDescription,
        sampleTiming: &timingInfo,
        sampleBufferOut: &sampleBuffer
    )

    return sampleBuffer
}

extension CMFormatDescription
{
    static func make(from pixelBuffer: CVPixelBuffer) -> CMFormatDescription? {
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        return formatDescription
    }
}

extension CMSampleTimingInfo
{
    static func make(from pixelBuffer: CVPixelBuffer) -> CMSampleTimingInfo? {
        let scale = CMTimeScale(NSEC_PER_SEC)
        let currentTimeNanosec = mach_absolute_time()

        let pts = CMTime(
            value: CMTimeValue(currentTimeNanosec),
            timescale: scale
        )
        return CMSampleTimingInfo(
            duration: .invalid,
            presentationTimeStamp: pts,
            decodeTimeStamp: .invalid
        )
    }
}

/// CVPixelBuffer -(crop)-> CVPixelBuffer
///
/// - Parameter cropRect: In camera's coordinate with top-left origin.
func croppedPixelBuffer(
    for pixelBuffer: CVPixelBuffer,
    cropRect: CGRect
) -> CVPixelBuffer?
{
    var cropRect = cropRect

    // Change origin to bottom-left.
    let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
    cropRect.origin.y = height - cropRect.origin.y - cropRect.size.height

    var image = CIImage(cvImageBuffer: pixelBuffer)
    image = image.cropped(to: cropRect)

    // Adjust origin. NOTE: CIImage is not in the original point after cropping.
    image = image.transformed(by: CGAffineTransform(translationX: -image.extent.origin.x, y: -image.extent.origin.y))

    var output: CVPixelBuffer? = nil
    CVPixelBufferCreate(nil, Int(image.extent.width), Int(image.extent.height), CVPixelBufferGetPixelFormatType(pixelBuffer), nil, &output)

    guard let output_ = output else { return nil }

    CIContext().render(image, to: output_)

    return output_
}

extension CMSampleBuffer
{
    func uiImage(deviceOrientation: UIDeviceOrientation) -> UIImage?
    {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }

        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect = CGRect(x: 0, y: 0, width: pixelBufferWidth, height: pixelBufferHeight)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        guard let cgimage = CIContext().createCGImage(ciImage, from: imageRect) else {
            return nil
        }

        let image = UIImage(cgImage: cgimage, scale: 0, orientation: deviceOrientation.estimatedImageOrientation ?? .right)
        return image
    }

    /// - Parameters:
    ///   - boundingBox: `CGRect` that has scale values from 0 to 1 in camera's coordinate with top-left origin.
    func cropped(boundingBox: CGRect) -> CMSampleBuffer?
    {
        withSampleBuffer(sampleBuffer: self) { pixelBuffer -> CVPixelBuffer? in
            let bufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let bufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))

            let convertedRect = CGRect(
                x: bufferWidth * boundingBox.minX,
                y: bufferHeight * boundingBox.minY,
                width: bufferWidth * boundingBox.width,
                height: bufferHeight * boundingBox.height
            )

            return croppedPixelBuffer(
                for: pixelBuffer,
                cropRect: convertedRect
            )
        }
    }
}
