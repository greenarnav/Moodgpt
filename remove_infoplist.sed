# Remove any line containing "Info.plist" that's part of a PBXBuildFile section
/\/* Info\.plist in/ d

# Remove any reference to Info.plist in the PBXResourcesBuildPhase section
/PBXResourcesBuildPhase/,/\);/ {
  /Info\.plist/ d
}
