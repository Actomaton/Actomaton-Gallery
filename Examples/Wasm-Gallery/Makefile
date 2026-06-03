# Wasm-Gallery (ElementaryUI + JavaScriptKit) build commands.
# Invoke targets here directly, or via the root Makefile's `*-Wasm-Gallery` targets.

WASM_NPM20 := npx -p node@20.19.5 -p npm@10.8.2 npm
WASM_NPM_CACHE ?= .npm-cache
SWIFT_BIN ?= $(if $(wildcard $(HOME)/.swiftly/bin/swift),$(HOME)/.swiftly/bin/swift,swift)
SWIFT_SDK_ID ?= swift-6.3.1-RELEASE_wasm
VITE_USE_EMBEDDED_SDK ?= 0
SWIFT_PACKAGE_RESOLVE_ARGS ?= --disable-sandbox
SWIFT_EXTRA_BUILD_ARGS ?= --disable-sandbox

.PHONY: bootstrap
bootstrap:
	$(SWIFT_BIN) package resolve $(SWIFT_PACKAGE_RESOLVE_ARGS) && \
	npm_config_cache="$(abspath $(WASM_NPM_CACHE))" SWIFT_BIN="$(SWIFT_BIN)" SWIFT_PACKAGE_RESOLVE_ARGS="$(SWIFT_PACKAGE_RESOLVE_ARGS)" $(WASM_NPM20) install

.PHONY: dev
dev:
	npm_config_cache="$(abspath $(WASM_NPM_CACHE))" SWIFT_BIN="$(SWIFT_BIN)" SWIFT_SDK_ID="$(SWIFT_SDK_ID)" SWIFT_EXTRA_BUILD_ARGS="$(SWIFT_EXTRA_BUILD_ARGS)" $(WASM_NPM20) run dev

.PHONY: build
build:
	npm_config_cache="$(abspath $(WASM_NPM_CACHE))" SWIFT_BIN="$(SWIFT_BIN)" SWIFT_SDK_ID="$(SWIFT_SDK_ID)" SWIFT_EXTRA_BUILD_ARGS="$(SWIFT_EXTRA_BUILD_ARGS)" VITE_USE_EMBEDDED_SDK="$(VITE_USE_EMBEDDED_SDK)" $(WASM_NPM20) run build

# Runs the same `swift build` invocation that the vite-plugin-swift-wasm executes,
# but directly — so compiler diagnostics reach the terminal instead of being
# swallowed by Rollup. Use this to diagnose `make build` failures.
.PHONY: build-swift
build-swift:
	$(SWIFT_BIN) build \
		--package-path . \
		--swift-sdk $(SWIFT_SDK_ID) \
		--configuration release \
		--product WasmGalleryApp \
		--toolset ./node_modules/@elementary-swift/vite-plugin-swift-wasm/utils/wasm-reactor-toolset.json \
		$(SWIFT_EXTRA_BUILD_ARGS)
