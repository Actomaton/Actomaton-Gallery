DESTINATION := -destination 'platform=iOS Simulator,name=iPhone 13 Pro'

build-SwiftUI-Basic:
	cd Examples/SwiftUI-Basic/ && \
	xcodebuild build -scheme Actomaton-Basic $(DESTINATION) | xcpretty

build-SwiftUI-Gallery:
	cd Examples/SwiftUI-Gallery/ && \
	xcodebuild build -scheme Actomaton-Gallery $(DESTINATION) | xcpretty

build-UIKit-Gallery:
	cd Examples/UIKit-Gallery/ && \
	xcodebuild build -scheme Actomaton-UIKit-Gallery $(DESTINATION) | xcpretty
