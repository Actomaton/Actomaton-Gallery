import "./styles.css";
import { runApplication } from "elementary-ui-browser-runtime";
import appInit from "virtual:swift-wasm?init&product=WasmGalleryApp";

// The real UI is rendered by the Swift/ElementaryUI side into `#app`.
// Drop the loading placeholder once ElementaryUI mounts real content there.
const appRoot = document.querySelector("#app");
if (appRoot) {
  new MutationObserver((_, observer) => {
    if (appRoot.querySelector(":scope > :not(.booting)")) {
      appRoot.querySelector(".booting")?.remove();
      observer.disconnect();
    }
  }).observe(appRoot, { childList: true });
}

void runApplication(appInit).catch((error) => {
  console.error("Failed to start Wasm Gallery:", error);
});
