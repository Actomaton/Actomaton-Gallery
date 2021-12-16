DESTINATION := -destination 'platform=iOS Simulator,name=iPhone 13 Pro'

build-SwiftUI-Basic:
	cd Examples/Actomaton-Basic.swiftpm && \
	xcodebuild build -scheme Actomaton-Basic $(DESTINATION) | xcpretty

build-SwiftUI-Gallery:
	cd Examples/SwiftUI-Gallery/ && \
	xcodebuild build -scheme Actomaton-Gallery $(DESTINATION) | xcpretty

build-UIKit-Gallery:
	cd Examples/UIKit-Gallery/ && \
	xcodebuild build -scheme Actomaton-UIKit-Gallery $(DESTINATION) | xcpretty

# e.g.
# make universal-link
# make universal-link path=counter?count=3
# make universal-link path=physics
# make universal-link path=physics/gravity-universe  # WARNING: iOS 15 SwiftUI double-push navigation doesn't work well
# make universal-link path=tab?index=2
universal-link:
	xcrun simctl openurl booted https://inamiy-universal-link.web.app/$(path)
