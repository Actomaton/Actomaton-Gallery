DESTINATION := -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
WASM_GALLERY_DIR := Examples/Wasm-Gallery

# NOTE: Only supports iOS, so `swift build` won't work.
.PHONY: build-package
build-package:
	cd GalleryApple && xcodebuild build -scheme GalleryApple-Package $(DESTINATION)

.PHONY: build-SwiftUI-Basic
build-SwiftUI-Basic:
	cd Examples/Actomaton-Basic.swiftpm && \
	xcodebuild build -scheme Actomaton-Basic $(DESTINATION)

.PHONY: build-SwiftUI-Gallery
build-SwiftUI-Gallery:
	cd Examples/SwiftUI-Gallery/ && \
	xcodebuild build -scheme Actomaton-Gallery $(DESTINATION)

.PHONY: build-UIKit-Gallery
build-UIKit-Gallery:
	cd Examples/UIKit-Gallery/ && \
	xcodebuild build -scheme Actomaton-UIKit-Gallery $(DESTINATION)

.PHONY: build-Favorite-Sync
build-Favorite-Sync:
	cd Examples/Favorite-Sync/ && \
	xcodebuild build -scheme Actomaton-Favorite-Sync $(DESTINATION)

.PHONY: build-VideoPlayer
build-VideoPlayer:
	cd Examples/VideoPlayer/ && \
	xcodebuild build -scheme Actomaton-VideoPlayer $(DESTINATION)

# Wasm-Gallery targets delegate to $(WASM_GALLERY_DIR)/Makefile.
# Pass overrides through, e.g. `make build-Wasm-Gallery SWIFT_SDK_ID=...`.
.PHONY: bootstrap-Wasm-Gallery
bootstrap-Wasm-Gallery:
	$(MAKE) -C $(WASM_GALLERY_DIR) bootstrap

.PHONY: dev-Wasm-Gallery
dev-Wasm-Gallery:
	$(MAKE) -C $(WASM_GALLERY_DIR) dev

.PHONY: build-Wasm-Gallery
build-Wasm-Gallery:
	$(MAKE) -C $(WASM_GALLERY_DIR) build

.PHONY: build-Wasm-Gallery-swift
build-Wasm-Gallery-swift:
	$(MAKE) -C $(WASM_GALLERY_DIR) build-swift

.PHONY: build-all
build-all: build-package build-SwiftUI-Basic build-SwiftUI-Gallery build-UIKit-Gallery build-Favorite-Sync build-VideoPlayer build-Wasm-Gallery

# e.g.
# make universal-link
# make universal-link path=counter?count=3
# make universal-link path=physics
# make universal-link path=physics/gravity-universe  # WARNING: iOS 15 SwiftUI double-push navigation doesn't work well
# make universal-link path=tab?index=2
.PHONY: universal-link
universal-link:
	xcrun simctl openurl booted https://inamiy-universal-link.web.app/$(path)
