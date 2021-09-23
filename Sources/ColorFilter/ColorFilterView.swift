import SwiftUI
import PhotosUI
import ActomatonStore
import PhotoPicker

@MainActor
public struct ColorFilterView: View
{
    // NOTE: These `SwiftUI.State`s can (and prefers to) belong to `Store`'s `State`.
    @SwiftUI.State
    private var photoDatas: [PhotoPickerData?] = []

    @SwiftUI.State
    private var isShowingPicker = false

    private let store: Store<ColorFilter.Action, ColorFilter.State>.Proxy

    public init(store: Store<ColorFilter.Action, ColorFilter.State>.Proxy)
    {
        self.store = store
    }

    public var body: some View
    {
        let image = photoDatas.first??.image
            ?? UIImage(named: "color.jpg", in: .module, with: nil)!

        return VStack {
            Image(uiImage: image)
                .resizable()
                .hueRotation(Angle(degrees: store.state.hue * 360))
                .saturation(store.state.saturation)
                .brightness(store.state.brightness)
                .contrast(store.state.contrast)

            controls()
        }
        .sheet(isPresented: $isShowingPicker) {
            PhotoPicker(
                datas: $photoDatas,
                configuration: pickerConfig,
                pattern: pickerPattern
            )
        }
    }

    private func controls() -> some View
    {
        VStack {
            Button("Select Image") {
                self.isShowingPicker = true
            }

            HStack {
                Text("Hue").frame(width: 100)
                Slider(
                    value: self.store.directStateBinding.hue,
                    in: 0 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Saturation").frame(width: 100)
                Slider(
                    value: self.store.directStateBinding.saturation,
                    in: 0 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Brightness").frame(width: 100)
                Slider(
                    value: self.store.directStateBinding.brightness,
                    in: -1 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Contrast").frame(width: 100)
                Slider(
                    value: self.store.directStateBinding.contrast,
                    in: -10 ... 10,
                    step: 0.01
                )
            }
        }
        .padding()
    }
}

private let pickerPattern: PickerPattern = .any(of: [.images, .livePhotos])

private let pickerConfig: PHPickerConfiguration = {
    var config = PHPickerConfiguration()
    config.filter = pickerPattern.filter
    config.selectionLimit = 1
    return config
}()

struct ColorFilterView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ColorFilterView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
