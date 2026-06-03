import { defineConfig } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

const useEmbeddedSDK = process.env.VITE_USE_EMBEDDED_SDK === "1";
const extraBuildArgs = process.env.SWIFT_EXTRA_BUILD_ARGS
  ?.split(/\s+/)
  .filter(Boolean);

export default defineConfig({
  plugins: [
    swiftWasm({
      extraBuildArgs,
      useEmbeddedSDK,
    }),
  ],
});
