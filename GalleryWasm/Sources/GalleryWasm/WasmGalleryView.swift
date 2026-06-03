import ElementaryUI

@View
struct WasmGalleryView
{
    @State var selectedExample: WasmExampleID = .counter

    var body: some View
    {
        div(.class("app-shell")) {
            div(.class("hero")) {
                p(.class("eyebrow")) { "Actomaton Gallery" }
                h1(.class("hero-title")) { "Wasm Gallery" }
                p(.class("hero-copy")) {
                    "A browser-native gallery powered by ElementaryUI. "
                    "Each example reuses a platform-agnostic reducer from GalleryCore, "
                    "validating a browser-native Actomaton path."
                }
            }

            div(.class("gallery-layout")) {
                div(.class("gallery-panel")) {
                    p(.class("panel-label")) { "Examples" }

                    for example in WasmExampleID.allCases {
                        ExamplePickerButton(
                            example: example,
                            isSelected: selectedExample == example,
                            onSelect: { selectedExample = example }
                        )
                    }
                }

                div(.class("gallery-panel")) {
                    switch selectedExample {
                    case .counter:
                        CounterPage()
                    case .syncCounters:
                        SyncCountersPage()
                    case .todo:
                        TodoPage()
                    case .stateDiagram:
                        StateDiagramPage()
                    case .stopwatch:
                        StopwatchPage()
                    case .downloader:
                        DownloaderPage()
                    case .colorFilter:
                        ColorFilterPage()
                    case .httpbin:
                        HttpBinPage()
                    case .github:
                        GitHubPage()
                    case .elemCellAutomaton:
                        ElemCellAutomatonPage()
                    case .gameOfLife:
                        GameOfLifePage()
                    case .physics:
                        PhysicsPage()
                    }
                }
            }
        }
    }
}
