import SwiftUI
import AVFoundation
import ActomatonUI
import CommonEffects
import Counter
import SyncCounters
import AnimationDemo
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import GitHub
import Downloader
import VideoPlayer
import VideoPlayerMulti
import VideoDetector
import GameOfLife
import Physics
import LiveEnvironments
import Home
import Root
import DebugRoot

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
//            RootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            HomeView_Previews.makePreviews(environment: .live, isMultipleScreens: false)

            //----------------------------------------
            // Per screen
            //----------------------------------------
//            CounterView_Previews.previews
//            SyncCountersView_Previews.previews
//            AnimationDemoView_Previews.previews
//            ColorFilterView_Previews.previews
//            TodoView_Previews.previews
//            StateDiagramView_Previews.previews
//            StopwatchView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            GitHubView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            DownloaderView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            VideoPlayerView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            VideoPlayerMultiView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            VideoDetectorView_Previews.previews
//            GameOfLife_RootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//            PhysicsRootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
        }
    }
}
