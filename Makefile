
checkout:
	git submodule update -i

build:
	xcodebuild -scheme FluidInterfaceKit -configuration Release -sdk iphoneos | xcbeautify
	xcodebuild -scheme FluidInterfaceKitRideauSupport -configuration Release -sdk iphoneos | xcbeautify
