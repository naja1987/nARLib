# builds a "fat" static library for iPhones and Simulator (for iOS 4)

#!/bin/bash
xcodebuild -sdk iphoneos4.1 "ARCHS=armv6 armv7" clean build
xcodebuild -sdk iphonesimulator4.1 "ARCHS=i386 x86_64" "VALID_ARCHS=i386 x86_64" clean build
lipo -output build/libnARLib.a -create build/Release-iphoneos/libnARLib.a build/Release-iphonesimulator/libnARLib.a
