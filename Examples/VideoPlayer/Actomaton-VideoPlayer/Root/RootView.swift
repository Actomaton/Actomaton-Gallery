import AVFoundation
import AVKit
import SwiftUI
import ActomatonUI

@MainActor
struct RootView: View
{
    private let store: Store<RootAction, RootState, RootEnvironment>

    @SwiftUI.State
    private var isInitialOnAppear: Bool = true

    init(store: Store<RootAction, RootState, RootEnvironment>)
    {
        self.store = store
    }

    var body: some View
    {
        ZStack {
            WithViewStore(store) { viewStore in
                main(viewStore)

                if let text = viewStore.dialogText {
                    dialog(text: text)
                }
            }
        }
    }

    private func main(_ viewStore: ViewStore<RootAction, RootState>) -> some View
    {
        VStack(spacing: 24) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(viewStore.mirroredChildren, id: \.label, content: { label, value in
                        Group {
                            Text("\(label)").bold()
                            valueText(value).truncationMode(.head)
                        }
                        .onTapGesture {
                            store.send(.showDialog(label: label, value: value))
                        }
                    })
                        .lineLimit(1)
                        .font(.callout)
                }
                .padding()
            }
            .border(Color.black)

            HStack(spacing: 16) {
                VStack(spacing: 16) {
                    controlButtons(viewStore)

                    Button(action: { store.send(.reloadRandom) }, label: {
                        Text("Reload")
                    })
                        .font(.body)

                    Slider(
                        value: viewStore.binding(get: \.sliderValue, onChange: RootAction.updateSliderValue),
                        in: 0 ... 1,
                        onEditingChanged: { isStarted in
                            if !isStarted {
                                store.send(.didFinishSliderSeeking)
                            }
                        }
                    )
                    .opacity(viewStore.isSliderEnabled ? 1 : 0.5)
                    .disabled(!viewStore.isSliderEnabled)
                }

                AVKit.VideoPlayer(player: store.environment.getPlayer())
                    .frame(maxWidth: 150, maxHeight: 150)
            }
        }
        .font(.title)
        .onAppear {
            guard isInitialOnAppear else { return }
            self.isInitialOnAppear = false

            store.send(.reloadRandom)
        }
        .padding()
    }

    @ViewBuilder
    private func valueText(_ value: String) -> some View
    {
        let hasOneOfPrefix: (_ prefixes: String...) -> Bool = {
            $0.first(where: { value.hasPrefix($0) }) != nil
        }

        if hasOneOfPrefix("paused", "unknown", "waitingToPlay") {
            Text("\(value)").foregroundColor(.red)
        } else if hasOneOfPrefix("readyToPlay", "playing") {
            Text("\(value)").foregroundColor(.green)
        } else {
            Text("\(value)")
        }
    }

    private func controlButtons(_ viewStore: ViewStore<RootAction, RootState>) -> some View
    {
        HStack(spacing: 16) {
            Button(action: { store.send(.advance(seconds: -10)) }, label: {
                Image(systemName: "gobackward.10")
            })
            playOrPauseButton(viewStore)
            Button(action: { store.send(.advance(seconds: 10)) }, label: {
                Image(systemName: "goforward.10")
            })
        }
    }

    @ViewBuilder
    private func playOrPauseButton(_ viewStore: ViewStore<RootAction, RootState>) -> some View
    {
        switch viewStore.playerState.playingStatus {
        case .playing, .waitingToPlay, .unknown:
            Button(action: { store.send(.pause) }, label: {
                Image(systemName: "pause.circle")
            })
        case .paused:
            Button(action: { store.send(.play) }, label: {
                Image(systemName: "play.circle")
            })
        }
    }

    // MARK: - Dialog

    private func dialog(text: String) -> some View
    {
        GeometryReader { g in
            ScrollView {
                Text(text)
                    .padding()
            }
            .clipped()
            .background(Color.white)
            .border(Color.black, width: 3)
            .frame(maxHeight: g.size.height)
            .padding()
            .fixedSize(horizontal: false, vertical: true)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
            // NOTE: Simulator needs this to close.
            .onTapGesture {
                store.send(.closeDialog)
            }
            .background(
                Color(white: 1, opacity: 0.75)
                    .ignoresSafeArea(.all, edges: .all)
            )
        }
        // NOTE: Only works for device.
        .onTapGesture {
            store.send(.closeDialog)
        }
    }
}

struct RootView_Previews: PreviewProvider
{
    static var previews: some View
    {
        RootView(
            store: Store(
                state: .init(),
                reducer: rootReducer(),
                environment: .init(
                    getPlayer: { nil },
                    testMode: .single(videoURL: { nil })
                )
            )
        )
    }
}
