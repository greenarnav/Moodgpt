#!/bin/bash
# Close Xcode if running
killall Xcode 2>/dev/null || true
sleep 1
# Open project
DIR="$(dirname "$0")"
open "$DIR/Moodgpt.xcodeproj" -a Xcode
