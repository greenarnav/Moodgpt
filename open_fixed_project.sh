#!/bin/bash

# Close Xcode if running
killall Xcode 2>/dev/null

# Clean Xcode caches
rm -rf ~/Library/Developer/Xcode/DerivedData/Moodgpt-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/DerivedData/Moodgpt-*

# Open the project
open "$(dirname "$0")/Moodgpt.xcodeproj"

cat << "INSTRUCTIONS"

======================= INSTRUCTIONS =======================
After Xcode opens:

1. Select the Moodgpt project in the navigator
2. Select the Moodgpt target
3. Go to Build Phases tab
4. Expand "Copy Bundle Resources"
5. If Info.plist is listed, REMOVE IT by selecting and clicking the - button
6. Go to Build Settings tab
7. Search for "Info.plist"
8. Ensure these settings:
   - Info.plist File = Moodgpt/Info.plist
   - Generate Info.plist File = NO
9. Clean the build folder (Product > Clean Build Folder)
10. Build the project

If you still get the same error:
- Go to File > Project Settings
- Change Build System to "Legacy Build System"
- Try building again
======================= INSTRUCTIONS =======================

INSTRUCTIONS
