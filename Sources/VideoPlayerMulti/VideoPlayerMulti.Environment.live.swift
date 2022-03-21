import VideoPlayer

extension Environment
{
    /// Live environment that separates `AVPlayer` per each `VideoPlayer` module.
    public static var live: Environment
    {
        // NOTE: Creates different `.live` `AVPlayer` environment for each player.
        let environment1 = VideoPlayer.Environment.live
        let environment2 = VideoPlayer.Environment.live

        return Environment(
            description: "Multiple AVPlayers",
            videoPlayer1: environment1,
            videoPlayer2: environment2
        )
    }
}
