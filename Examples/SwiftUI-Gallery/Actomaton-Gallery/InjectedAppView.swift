import SwiftUI
import ActomatonUI
import Tabs
import Home
import Root
import DebugRoot
import UserSession
import CommonEffects
import LiveEnvironments
import Inject

// Additional examples import.
import Counter
import SyncCounters
import AnimationDemo
import ColorFilter
import Todo
import StateDiagram
import Stopwatch
import HttpBin
import GitHub
import Downloader
import VideoPlayer
import VideoPlayerMulti
import VideoDetector
import ElemCellAutomaton
import GameOfLife
import Physics

/// Inject hot-reload host and the edit-target view for hot reload.
///
/// ## How to activate hot-reloading
///
/// 1. Install `InjectionIII.app` from https://github.com/johnno1962/InjectionIII/releases
///    into `/Applications` (or `InjectionNext.app` from the same author as a
///    drop-in replacement that doesn't depend on Xcode build logs).
/// 2. Launch `InjectionIII`, choose `Open Project…` and select this workspace
///    or the enclosing `Package.swift`.
/// 3. Run the app on the iOS Simulator in `Debug`. The console should print
///    `💉 InjectionIII connected …` once attached.
/// 4. Edit this view's body and save — the simulator re-renders without a rebuild.
///
/// Project-side prerequisites already wired up here:
/// - `OTHER_LDFLAGS = -Xlinker -interposable` on the app target's Debug config.
/// - `EMIT_FRONTEND_COMMAND_LINES = YES` on Debug (required for Xcode 16.3+,
///   which otherwise no longer logs Swift compile commands that InjectionIII
///   parses).
/// - `Inject` 1.6.0+ — earlier versions do not redraw reliably under Swift 6
///   strict concurrency.
///
/// - Important:
/// `@ObserveInjection` (and `.enableInjection()`) must be applied
/// **inside the body of the view whose code you are editing**, not from a parent.
@MainActor
struct InjectedAppView: View
{
    @ObserveInjection var inject

    let store: Store<DebugRoot.Action<Root.Action>, DebugRoot.State<Root.State>, HomeEnvironment>

    @ViewBuilder
    private var _body: some View {
        AppView(store: store)

//        RootView_Previews.makePreviews(state: .initialState, environment: .live, isMultipleScreens: false)
//        HomeView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//
//        ----------------------------------------
//        Per screen
//        ----------------------------------------
//        CounterView_Previews.previews
//        SyncCountersView_Previews.previews
//        AnimationDemoView_Previews.previews
//        ColorFilterView_Previews.previews
//        TodoView_Previews.previews
//        StateDiagramView_Previews.previews
//        StopwatchView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        HttpBinView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        GitHubView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        DownloaderView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoPlayerView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoPlayerMultiView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        VideoDetectorView_Previews.previews
//        ElemCellAutomaton_RootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        GameOfLife_RootView_Previews.makePreviews(environment: .live, isMultipleScreens: false)
//        PhysicsRootView_Previews.makePreviews(state: .doublePendulum, environment: .live, isMultipleScreens: false)
    }

    var body: some View
    {
        _body.enableInjection()
    }
}
