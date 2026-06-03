import AVFoundation

internal struct VideoOutputHandler
{
    let delegate: VideoOutputDelegate

    init(runner: @escaping (CMSampleBuffer) -> Void)
    {
        self.delegate = VideoOutputDelegate(runner: runner)
    }
}

internal class VideoOutputDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
{
    private let runner: (CMSampleBuffer) -> Void

    init(runner: @escaping (CMSampleBuffer) -> Void)
    {
        self.runner = runner
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        self.runner(sampleBuffer)
    }
}
