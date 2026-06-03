import ElementaryUI
import JavaScriptEventLoop

/// Public entry point for the Wasm Gallery web UI.
///
/// The runnable harness in `Examples/Wasm-Gallery` only needs to call ``run()`` from its
/// `@main`; all views, example registry, and demo machines stay internal to this package.
public enum WasmGallery
{
    /// Mounts the gallery into the `#app` DOM element.
    public static func run()
    {
        // Hook Swift Concurrency's global executor to the browser event loop so async
        // effects (e.g. Stopwatch's timer, StateDiagram's `Task.sleep`) actually resume.
        // ElementaryUI renders synchronously and never installs this itself.
        // NOTE: Must run before any `Task` is created.
        JavaScriptEventLoop.installGlobalExecutor()

        let app = Application(WasmGalleryView())
        app.mount(in: "#app")
    }
}
