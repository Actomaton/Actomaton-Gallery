import SwiftUI
import PhotosUI
import ActomatonUI
import PhotoPicker
import Utilities

@MainActor
public struct ColorFilterView: View
{
    // NOTE: These `SwiftUI.State`s can (and prefers to) belong to `Store`'s `State`.
    @SwiftUI.State
    private var photoDatas: [PhotoPickerData?] = []

    @SwiftUI.State
    private var isShowingPicker = false

    private let store: Store<ColorFilter.Action, ColorFilter.State, Void>

    @ObservedObject
    private var viewStore: ViewStore<ColorFilter.Action, ColorFilter.State>

    public init(store: Store<ColorFilter.Action, ColorFilter.State, Void>)
    {
        let _ = Debug.print("ColorFilterView.init")

        self.store = store
        self.viewStore = store.viewStore
    }

    public var body: some View
    {
        let _ = Debug.print("ColorFilterView.body")

        let image = photoDatas.first??.image
            ?? UIImage(named: "color.jpg", in: .module, with: nil)!

        return VStack {
            Image(uiImage: image)
                .resizable()
                .hueRotation(Angle(degrees: viewStore.hue * 360))
                .saturation(viewStore.saturation)
                .brightness(viewStore.brightness)
                .contrast(viewStore.contrast)

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
                    value: self.viewStore.directBinding.hue,
                    in: 0 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Saturation").frame(width: 100)
                Slider(
                    value: self.viewStore.directBinding.saturation,
                    in: 0 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Brightness").frame(width: 100)
                Slider(
                    value: self.viewStore.directBinding.brightness,
                    in: -1 ... 1,
                    step: 0.01
                )
            }
            HStack {
                Text("Contrast").frame(width: 100)
                Slider(
                    value: self.viewStore.directBinding.contrast,
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

public struct ColorFilterView_Previews: PreviewProvider
{
    public static var previews: some View
    {
        ColorFilterView(
            store: .init(
                state: .init(),
                reducer: ColorFilter.reducer
            )
        )
    }
}
