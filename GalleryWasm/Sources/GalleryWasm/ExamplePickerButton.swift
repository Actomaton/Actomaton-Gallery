import ElementaryUI

@View
struct ExamplePickerButton
{
    let example: WasmExampleID
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View
    {
        button(
            .type(.button),
            .class(isSelected ? "example-button is-selected" : "example-button")
        ) {
            span(.class("material-symbols-outlined example-icon")) { example.icon }
            span(.class("example-title")) { example.title }
        }
        .onClick { _ in
            onSelect()
        }
    }
}
