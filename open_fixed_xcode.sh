#!/bin/bash

# Close Xcode if running
killall Xcode 2>/dev/null || true
sleep 1

# Remove any lingering Xcode workspace state
rm -rf Moodgpt.xcodeproj/project.xcworkspace/xcuserdata
rm -rf Moodgpt.xcodeproj/xcuserdata

# Clean derived data one more time
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*

# Open the project
open Moodgpt.xcodeproj

echo "
======================= IMPORTANT =======================
In Xcode:

1. Clean the build folder: Product > Clean Build Folder
2. Manual check these settings:
   - Select Project > Target > Build Phases
   - Make sure Info.plist is NOT in Copy Bundle Resources
   - Go to Build Settings
   - Make sure INFOPLIST_FILE = Moodgpt/Info.plist
   - Make sure GENERATE_INFOPLIST_FILE = NO

3. If still having issues:
   - Try Product > Clean Build Folder again
   - Try building with Command + B
======================= IMPORTANT =======================
"
