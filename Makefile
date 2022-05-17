
.PHONY: checkout
checkout:
	git submodule update --init --recursive

.PHONY: build
build:
	xcodebuild -scheme FluidInterfaceKit -configuration Release -sdk iphoneos | xcbeautify
	xcodebuild -scheme FluidInterfaceKitRideauSupport -configuration Release -sdk iphoneos | xcbeautify
