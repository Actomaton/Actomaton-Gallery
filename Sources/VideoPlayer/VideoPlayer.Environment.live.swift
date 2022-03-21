import AVFoundation

extension Environment
{
    public static var live: Environment
    {
        /// Effectful references.
        class Refs {
            var player: AVPlayer?
        }

        let refs = Refs()

        return .init(
            getPlayer: { refs.player },
            setPlayer: { refs.player = $0 }
        )
    }
}
