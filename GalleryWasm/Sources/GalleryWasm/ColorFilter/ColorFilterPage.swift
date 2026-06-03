import ElementaryUI

@View
struct ColorFilterPage
{
    @State var machine: ColorFilterDemoMachine

    init()
    {
        _machine = State(wrappedValue: makeColorFilterDemoMachine())
    }

    var body: some View
    {
        div {
            p(.class("counter-kicker")) { "ColorFilter" }
            h2(.class("counter-heading")) { "Live CSS Filters" }
            p(.class("counter-copy")) {
                "Sliders feed the shared ColorFilter reducer; its state maps to a CSS filter applied "
                "to the canvas below — a state→CSS binding with no platform image APIs."
            }

            div(.class("color-canvas"), .style(["filter": filterValue])) { "" }

            div(.class("color-sliders")) {
                ColorSlider(
                    label: "Hue",
                    value: machine.state.colorFilter.hue,
                    minValue: "0", maxValue: "1",
                    onChange: { machine.send(.setHue($0)) }
                )
                ColorSlider(
                    label: "Saturation",
                    value: machine.state.colorFilter.saturation,
                    minValue: "0", maxValue: "2",
                    onChange: { machine.send(.setSaturation($0)) }
                )
                ColorSlider(
                    label: "Brightness",
                    value: machine.state.colorFilter.brightness,
                    minValue: "-1", maxValue: "1",
                    onChange: { machine.send(.setBrightness($0)) }
                )
                ColorSlider(
                    label: "Contrast",
                    value: machine.state.colorFilter.contrast,
                    minValue: "0", maxValue: "2",
                    onChange: { machine.send(.setContrast($0)) }
                )
            }

            button(.type(.button), .class("counter-action")) { "Reset" }
                .onClick { _ in machine.send(.reset) }
        }
    }

    private var filterValue: String
    {
        let s = machine.state.colorFilter
        // Build the angle unit by concatenation so a formatter can't split `<n>deg` into invalid `<n> deg`.
        let hueAngle = String(s.hue * 360) + "deg"
        return "hue-rotate(\(hueAngle)) saturate(\(s.saturation)) brightness(\(1 + s.brightness)) contrast(\(s.contrast))"
    }
}

@View
struct ColorSlider
{
    var label: String
    var value: Double
    var minValue: String
    var maxValue: String
    var onChange: (Double) -> Void

    var body: some View
    {
        div(.class("color-slider")) {
            span(.class("color-slider-label")) { label }
            input(
                .custom(name: "type", value: "range"),
                .custom(name: "min", value: minValue),
                .custom(name: "max", value: maxValue),
                .custom(name: "step", value: "0.01"),
                .class("color-slider-input")
            )
            .bindValue(
                Binding<Double?>(
                    get: { value },
                    set: { onChange($0 ?? 0) }
                )
            )
        }
    }
}
