# Instructions for Building and Submitting MoodGPT to App Store

Follow these steps to build and submit a new version of MoodGPT to the App Store:

## Issues Fixed

1. **HealthKit Usage Descriptions** - Added missing HealthKit usage descriptions in the app's Info.plist to resolve ITMS-90683 errors.

2. **Permission Requests Implementation** - Implemented proper permission requests for:
   - Contacts: To show contacts' mood based on location
   - Location: To display current city mood and nearby contacts
   - Calendar: To correlate mood with scheduled events
   - HealthKit: To analyze how physical activity affects mood patterns

3. **Permission UI** - Added permission banners in the Home screen that prompt users to enable required permissions if not already granted.

4. **iOS 17 Compatibility** - Updated Calendar APIs to use the latest iOS 17 permission request methods while maintaining backward compatibility.

## 1. Open the Xcode Project
- Open "Moodgpt.xcodeproj" in Xcode

## 2. Verify Project Settings
Confirm that all the required usage descriptions are properly included:
- Select the project in Xcode's Project Navigator
- Select "Moodgpt" target
- Go to "Build Settings" tab
- Search for "Info.plist" 
- Verify that these keys are included:
  - NSHealthShareUsageDescription
  - NSHealthUpdateUsageDescription
  - NSContactsUsageDescription
  - NSLocationWhenInUseUsageDescription
  - NSLocationAlwaysUsageDescription
  - NSLocationAlwaysAndWhenInUseUsageDescription
  - NSCalendarUsageDescription

## 3. Clean the Build Folder
- Select "Product > Clean Build Folder" in Xcode menu

## 4. Archive the Project
- Select "Product > Archive" in Xcode menu

## 5. Validate and Upload
- In the Archives window that appears after archiving:
  - Select "Validate App" and follow the prompts
  - Then select "Distribute App" and choose "App Store Connect"
  - Follow the remaining prompts to upload to App Store Connect

## 6. Submit for Review
- Log in to App Store Connect (https://appstoreconnect.apple.com)
- Navigate to your app
- Create a new version
- Upload screenshots and metadata if needed
- Select "Submit for Review"

These steps should resolve the App Store rejection issues and ensure that the app correctly requests and handles all required permissions. 