# MoodGPT Permission Requests Guide

This document explains how MoodGPT handles and requests various permissions to provide its full functionality.

## Permission Requests in MoodGPT

MoodGPT requests several permissions to enhance the user experience and provide meaningful mood analysis:

### 1. Location Permissions

**Purpose**: MoodGPT uses location data to:
- Show the current city's collective mood
- Find nearby contacts and their moods
- Correlate location with mood patterns

**When requested**: 
- At app launch
- Via permission banners in the Home screen
- In the Maps tab when accessing location features

**Key in Info.plist**:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

### 2. Contacts Permissions

**Purpose**: MoodGPT uses contacts data to:
- Display contacts and their current mood based on location
- Allow sharing mood updates with contacts
- Provide insights on social interactions

**When requested**:
- When accessing the Contacts tab
- Via permission banners in the Home screen
- When attempting to share mood with contacts

**Key in Info.plist**:
- `NSContactsUsageDescription`

### 3. Calendar Permissions

**Purpose**: MoodGPT uses calendar data to:
- Correlate scheduled events with mood patterns
- Provide insights on how events affect mood
- Suggest optimal scheduling based on mood patterns

**When requested**:
- Via permission banners in the Home screen
- When viewing calendar events in the app
- In settings when enabling calendar integration

**Key in Info.plist**:
- `NSCalendarUsageDescription`

### 4. HealthKit Permissions

**Purpose**: MoodGPT uses health data to:
- Analyze how physical activity affects mood
- Track relationships between sleep, steps, and mood
- Provide insights on health-mood correlations

**When requested**:
- At app launch
- Via permission banners in the Home screen
- In settings when enabling health data sync

**Key in Info.plist**:
- `NSHealthShareUsageDescription`
- `NSHealthUpdateUsageDescription`

## User Experience

### Home Screen Permission Banners

The app displays permission banners on the Home screen for any permissions that haven't been granted. These banners:
- Explain why each permission is needed
- Provide a direct way to enable the permission
- Are removed once permission is granted

### Settings Integration

In the Settings tab, users can manage which health data types they want to sync with MoodGPT:
- Steps
- Sleep
- Mindfulness
- Heart Rate

### Privacy-First Approach

MoodGPT is designed with privacy in mind:
- All data processing happens on-device
- Users can disable any permission at any time
- The app degrades gracefully if permissions are not granted
- No data is shared with third parties without explicit consent

## Implementation Details

All permission requests are implemented using the latest iOS APIs, with backward compatibility for older iOS versions where needed. The app follows Apple's guidelines for requesting permissions at appropriate times and with clear explanations. 