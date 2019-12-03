#!/bin/bash

go install golang.org/x/mobile/cmd/gomobile
go install golang.org/x/mobile/cmd/gobind

mkdir -p ../ios/Frameworks

# Generate objective-c and java interfaces for calling the go code from native code.
gomobile bind -target android -o ../android/Mobile.aar .
gomobile bind -target ios -o ../ios/Frameworks/Mobile.framework .
