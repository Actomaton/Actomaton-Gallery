import SwiftUI
import ActomatonUI
import VideoCapture

@MainActor
public struct VideoDetectorView: View
{
    private let store: Store<VideoDetector.Action, VideoDetector.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<VideoDetector.Action, VideoDetector.State>

    public init(store: Store<VideoDetector.Action, VideoDetector.State, Void>)
    {
        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        Group {
            // Has session
            if let sessionID = self.captureState.sessionState.sessionID {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.5).ignoresSafeArea()

                    VideoPreviewView(
                        sessionID: sessionID,
                        detectedRects: viewStore.detectedRects
                    )
                    .map { $0.ignoresSafeArea() }

                    self.controlView()
                }
            }
            // No session
            else {
                ZStack(alignment: .center) {
                    self.noSessionView()
                }
            }
        }
        .onAppear {
            self.sendToCapture(.makeSession)
        }
    }

    private func controlView() -> some View
    {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(viewStore.detectedTextImages, id: \.self) {
                    Image(uiImage: $0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .border(Color.yellow)
                }
            }

            Picker("Detector Mode", selection: viewStore.directBinding.detectMode) {
                Text("Face").tag(VideoDetector.State.DetectMode.face)
                Text("Text Rect").tag(VideoDetector.State.DetectMode.textRect)
                Text("Vision").tag(VideoDetector.State.DetectMode.textRecognitionIOSVision)
            }
            .pickerStyle(SegmentedPickerStyle())

            switch viewStore.detectMode {
            case .textRecognitionIOSVision:
                Text("\(viewStore.detectedTexts.count): \(viewStore.detectedTexts.joined(separator: ", "))")
                    .lineLimit(3)
                    .font(.title3)
                    .padding()
            default:
                Text(self.captureState.sessionState.description + ", detect = \(viewStore.detectedRects.count)")
                    .lineLimit(3)
                    .font(.title3)
                    .padding()
            }

            HStack {
                Button { self.sendToCapture(.removeSession) }
                    label: { Image(systemName: "bolt.slash") }
                    .font(.title)

                Spacer()

                if case .running = self.captureState.sessionState {
                    Button { self.sendToCapture(.stopSession) }
                        label: { Image(systemName: "stop.circle") }
                        .font(.title)
                }
                else {
                    Button { self.sendToCapture(.startSession) }
                        label: { Image(systemName: "play.circle") }
                        .font(.title)
                }

                Spacer()

                Button { self.sendToCapture(.changeCameraPosition) }
                    label: { Image(systemName: "camera.rotate") }
                    .font(.title)
            }
        }
        .padding()
        .background(
            Color(white: 1, opacity: 0.75)
                .edgesIgnoringSafeArea(.all)
        )
    }

    private func noSessionView() -> some View
    {
        VStack(spacing: 10) {
            // Status
            Text(self.captureState.sessionState.description)
                .font(.title)

            Button { self.sendToCapture(.makeSession) }
                label: {
                    Image(systemName: "bolt")
                    Text("Make Session")
                }
            .font(.title)
        }
        .background(
            Color(white: 1, opacity: 0.75)
                .edgesIgnoringSafeArea(.all)
        )
    }

    // MARK: - Helpers

    private var captureState: VideoCapture.State
    {
        self.viewStore.videoCapture
    }

    private func sendToCapture(_ action: VideoCapture.Action)
    {
        self.store.send(.videoCapture(action))
    }
}

// MARK: - Preview

public struct VideoDetectorView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        let sessionID = SessionID.testID

        @MainActor
        func makeView(sessionState: VideoCapture.State.SessionState) -> some View {
            VideoDetectorView(
                store: .init(
                    state: VideoDetector.State(
                        detectMode: .face,
                        detectedRects: [.zero, .zero],
                        detectedTextImages: [],
                        detectedTexts: [],
                        videoCapture: .init(sessionState: sessionState)
                    ),
                    reducer: VideoDetector.reducer
                )
            )
        }

        return Group {
            let sessionState: VideoCapture.State.SessionState
                = .running(sessionID)
//                = .noSession

            makeView(sessionState: sessionState)
                .previewDevice("iPhone 11 Pro")

//            makeView(sessionState: .idle(sessionID))
//                .previewLayout(.fixed(width: 320, height: 480))
//
//            makeView(sessionState: .running(sessionID))
//                .previewLayout(.fixed(width: 480, height: 320))
//                .previewDisplayName("Landscape")
//
//            makeView(sessionState: .noSession)
//                .previewLayout(.fixed(width: 320, height: 480))
        }
    }
}
