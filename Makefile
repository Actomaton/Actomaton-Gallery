DESTINATION := -destination 'platform=iOS Simulator,name=iPhone 14 Pro'

# NOTE: Only supports iOS, so `swift build` won't work.
.PHONY: build-package
build-package:
	xcodebuild build -scheme Actomaton-Gallery-Package $(DESTINATION) | xcpretty

.PHONY: build-SwiftUI-Basic
build-SwiftUI-Basic:
	cd Examples/Actomaton-Basic.swiftpm && \
	xcodebuild build -scheme Actomaton-Basic $(DESTINATION) | xcpretty

.PHONY: build-SwiftUI-Gallery
build-SwiftUI-Gallery:
	cd Examples/SwiftUI-Gallery/ && \
	xcodebuild build -scheme Actomaton-Gallery $(DESTINATION) | xcpretty

.PHONY: build-UIKit-Gallery
build-UIKit-Gallery:
	cd Examples/UIKit-Gallery/ && \
	xcodebuild build -scheme Actomaton-UIKit-Gallery $(DESTINATION) | xcpretty

.PHONY: build-Favorite-Sync
build-Favorite-Sync:
	cd Examples/Favorite-Sync/ && \
	xcodebuild build -scheme Actomaton-Favorite-Sync $(DESTINATION) | xcpretty

.PHONY: build-VideoPlayer
build-VideoPlayer:
	cd Examples/VideoPlayer/ && \
	xcodebuild build -scheme Actomaton-VideoPlayer $(DESTINATION) | xcpretty

# e.g.
# make universal-link
# make universal-link path=counter?count=3
# make universal-link path=physics
# make universal-link path=physics/gravity-universe  # WARNING: iOS 15 SwiftUI double-push navigation doesn't work well
# make universal-link path=tab?index=2
.PHONY: universal-link
universal-link:
	xcrun simctl openurl booted https://inamiy-universal-link.web.app/$(path)
