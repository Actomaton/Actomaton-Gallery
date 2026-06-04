import { defineConfig } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

const useEmbeddedSDK = process.env.VITE_USE_EMBEDDED_SDK === "1";
const extraBuildArgs = process.env.SWIFT_EXTRA_BUILD_ARGS
  ?.split(/\s+/)
  .filter(Boolean);
const basePath = process.env.VITE_BASE_PATH || "/";
const base = basePath.endsWith("/") ? basePath : `${basePath}/`;

export default defineConfig({
  base,
  plugins: [
    swiftWasm({
      extraBuildArgs,
      useEmbeddedSDK,
    }),
  ],
});
