import Foundation

enum Constants
{
    // Public Blender Foundation open-movies + Apple HLS sample.
    // The previous Google `gtv-videos-bucket` URLs returned 403 after Google made
    // that bucket private.
    static let videoURLs: [URL] = [
        "https://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4",
        "https://archive.org/download/ElephantsDream/ed_1024_512kb.mp4",
        "https://archive.org/download/Sintel/sintel-2048-stereo_512kb.mp4",
        "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
    ]
        .compactMap { URL(string: $0) }

    // Short 10-second clips from test-videos.co.uk.
    static let shortVideoURLs: [URL] = [
        "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4",
        "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_2MB.mp4",
        "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_5MB.mp4",
    ]
        .compactMap { URL(string: $0) }
}
