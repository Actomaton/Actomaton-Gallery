import SwiftUI
import ActomatonUI

@MainActor
public struct DownloaderView: View
{
    private let store: Store<Downloader.Action, Downloader.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<Downloader.Action, Downloader.State>

    public init(store: Store<Downloader.Action, Downloader.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        VStack(spacing: 20) {
            Group {
                let runningTasks = viewStore.runningTasks.map { $0 }

                ForEach(runningTasks, id: \.key) { downloadID, progress in
                    progressView(downloadID: downloadID)
                }
            }
            .padding(.horizontal)

            Group {
                Button(action: { self.store.send(.downloadAll) }) {
                    Text("Download All")
                }
                Button(action: { self.store.send(.cancelAll) }) {
                    Text("Cancel All")
                }
            }
            .padding(.top)
            .font(.system(size: 36))
        }
        .onAppear {
            self.store.send(.downloadAll)
        }
    }

    @ViewBuilder
    private func progressView(downloadID: DownloadID) -> some View
    {
        HStack(alignment: .center, spacing: 20) {
            let downloadState = viewStore.runningTasks[downloadID, default: .waiting(progress: 0)]
            let progressValue = downloadState.progressValue

            ProgressView(
                "\(downloadID): \(downloadState.description)",
                value: progressValue,
                total: 1
            )
            .animation(.easeInOut(duration: 0.3), value: progressValue)

            HStack {
                runOrPauseButton(downloadID: downloadID)
                    .frame(width: 30)

                Button(action: { self.store.send(.cancel(id: downloadID)) }) {
                    Image(systemName: "x.circle")
                }
                .frame(width: 30)
            }
            .font(.system(size: 28))
            .frame(alignment: .trailing)
        }
    }

    @ViewBuilder
    private func runOrPauseButton(downloadID: DownloadID) -> some View
    {
        let progress = viewStore.runningTasks[downloadID, default: .waiting(progress: 0)]

        Button(
            action: {
                if progress.canRun {
                    self.store.send(.resume(id: downloadID))
                }
                else if progress.canPause {
                    self.store.send(.pause(id: downloadID))
                }
            },
            label: {
                if progress.canRun {
                    Image(systemName: "play.circle")
                }
                else if progress.canPause {
                    Image(systemName: "pause.circle")
                }

            }
        )
    }
}

public struct DownloaderView_Previews: PreviewProvider
{
    @ViewBuilder
    public static func makePreviews(environment: Environment, isMultipleScreens: Bool) -> some View
    {
        DownloaderView(
            store: Store(
                state: .init(),
                reducer: reducer,
                environment: environment
            )
            .noEnvironment
        )
    }

    /// - Note: Uses mock environment.
    public static var previews: some View
    {
        self.makePreviews(
            environment: .init(
                download: { _, _ in AsyncStream { nil } }
            ),
            isMultipleScreens: true
        )
    }
}
