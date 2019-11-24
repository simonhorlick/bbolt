#!/bin/bash

go install golang.org/x/mobile/cmd/gomobile
go install golang.org/x/mobile/cmd/gobind

mkdir ../ios/Frameworks

# Generate objective-c and java interfaces for calling the go code from native code.
# TODO(simon): Build for android
#gomobile bind -target android -o ../android/? .
gomobile bind -target ios -o ../ios/Frameworks/Mobile.framework .
