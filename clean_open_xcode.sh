#!/bin/bash
# Close Xcode
killall Xcode 2>/dev/null || true
sleep 2
# Clean caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Open project
open "$(dirname "$0")/Moodgpt.xcodeproj"
