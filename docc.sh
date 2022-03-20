#! /bin/sh

xcodebuild docbuild -scheme FluidInterfaceKit -derivedDataPath .build -destination 'generic/platform=iOS'

ARCHIVE_PATH=".build/Build/Products/Debug-iphoneos/FluidInterfaceKit.doccarchive"

$(xcrun --find docc) process-archive \
transform-for-static-hosting $ARCHIVE_PATH \
--output-path docs \
--hosting-base-path "FluidInterfaceKit"

# swift package --allow-writing-to-directory [path-to-docs-directory] \
#     generate-documentation --target "FluidInterfaceKit" \
#     --disable-indexing \
#     --transform-for-static-hosting \
#     --hosting-base-path "FluidInterfaceKit" \
#     --output-path docs