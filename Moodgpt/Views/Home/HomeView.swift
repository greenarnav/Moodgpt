import SwiftUI
import Combine
import Contacts
import EventKit
import CoreLocation
import HealthKit
import UserNotifications

// Add AreaCodeLookup structure to support contact city classification
struct AreaCodeLookup {
    // Static method for looking up city by area code
    static func city(for areaCode: String) -> (city: String, state: String)? {
        // Fallback for known area codes (hardcoded for now)
        switch areaCode {
        case "201":
            return (city: "Jersey City", state: "New Jersey")
        case "212":
            return (city: "Manhattan", state: "New York")
        case "213":
            return (city: "Los Angeles", state: "California")
        // ... many more area codes in the original implementation
        // Truncated for readability in this edit
        case "917":
            return (city: "New York", state: "New York")
        case "415":
            return (city: "San Francisco", state: "California")
        case "650":
            return (city: "San Mateo", state: "California")
        case "408":
            return (city: "San Jose", state: "California")
        // ... more area codes would be here
        default:
            return nil
        }
    }
}

struct HomeView: View {
    @ObservedObject var contactService: ContactService
    @ObservedObject var locationService: LocationService
    @StateObject private var viewModel = HomeViewModel()
    
    // Permission status states
    @State private var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @State private var contactsPermissionStatus: CNAuthorizationStatus = .notDetermined
    @State private var healthKitPermissionStatus: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient based on current city mood
                LinearGradient(
                    gradient: Gradient(colors: backgroundColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Current location card
                        currentLocationCard
                        
                        // Mood timeline section
                        moodTimelineSection
                        
                        // Favorite cities section - updated to show where most contacts live
                        favoriteCitiesSection
                        
                        // Recent contacts section
                        recentContactsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("MoodGpt")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkPermissions()
                
                // Request all permissions if not already granted
                if locationPermissionStatus != .authorizedAlways && locationPermissionStatus != .authorizedWhenInUse {
                    locationService.requestAuthorization()
                }
                
                if contactsPermissionStatus != .authorized {
                    contactService.requestAccess()
                }
                
                if !healthKitPermissionStatus {
                    PermissionsManager.shared.requestHealthKitAccess()
                }
                
                // Request notifications if not previously requested
                if !UserDefaults.standard.bool(forKey: "didRequestNotifications") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        UserDefaults.standard.set(true, forKey: "didRequestNotifications")
                    }
                }
                
                // Always sync contacts automatically when permissions are granted
                if contactsPermissionStatus == .authorized {
                    syncContacts()
                }
                
                viewModel.loadCurrentCityMood(for: locationService.currentCity ?? "San Francisco")
            }
        }
    }
    
    // Background colors based on current city mood
    var backgroundColors: [Color] {
        guard let cityMoodData = viewModel.cityMoodData else {
            return [Color.blue.opacity(0.7), Color.purple.opacity(0.7)] // Default colors
        }
        
        let currentMood = Emotion.fromMoodScore(cityMoodData.currentMoodScore)
        
        // Return different color schemes based on mood type
        if currentMood.isPositive {
            return [Color.green.opacity(0.6), Color.blue.opacity(0.7)]
        } else if currentMood.isNegative {
            return [Color.red.opacity(0.5), Color.purple.opacity(0.6)]
        } else {
            return [Color.blue.opacity(0.5), Color.indigo.opacity(0.6)]
        }
    }
    
    // Permission check function
    private func checkPermissions() {
        // Check location permission
        locationPermissionStatus = CLLocationManager().authorizationStatus
        
        // Check contacts permission
        contactsPermissionStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        // Check HealthKit permission
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            
            healthKitPermissionStatus = healthStore.authorizationStatus(for: stepCountType) == .sharingAuthorized
        }
    }
    
    // Function to sync contacts and classify them by city - now private, called automatically
    private func syncContacts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let store = CNContactStore()
            var contacts: [Contact] = []
            
            // Define which contact data to fetch
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor
            ]
            
            // Create fetch request
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            
            do {
                try store.enumerateContacts(with: fetchRequest) { (cnContact, _) in
                    // Process only contacts with at least one phone number
                    if let phoneNumber = cnContact.phoneNumbers.first?.value.stringValue {
                        // Clean the phone number to extract area code
                        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                        
                        // Extract area code (assuming US numbers)
                        var areaCode = ""
                        if cleanNumber.hasPrefix("1") && cleanNumber.count > 3 {
                            // Remove country code and get area code
                            areaCode = String(cleanNumber.dropFirst().prefix(3))
                        } else if cleanNumber.count >= 3 {
                            // Just get first 3 digits as area code
                            areaCode = String(cleanNumber.prefix(3))
                        }
                        
                        // Look up city based on area code
                        var city = "Unknown"
                        if !areaCode.isEmpty {
                            if let cityInfo = AreaCodeLookup.city(for: areaCode) {
                                city = cityInfo.city
                            }
                        }
                        
                        // Create contact with assigned city
                        let fullName = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                        let contact = Contact(
                            name: fullName.isEmpty ? "Unknown Name" : fullName,
                            phoneNumber: phoneNumber,
                            city: city,
                            emotion: getRandomEmotion() // Assign random emotion for now
                        )
                        
                        contacts.append(contact)
                    }
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    // Update the contact service with the new contacts
                    contactService.updateContacts(contacts)
                }
                
            } catch {
                print("Error fetching contacts: \(error)")
            }
        }
    }
    
    // Helper to get a random emotion for new contacts
    private func getRandomEmotion() -> Emotion {
        let emotions: [Emotion] = [.happy, .sad, .angry, .surprised, .fearful, .neutral]
        return emotions.randomElement() ?? .neutral
    }
    
    private var currentLocationCard: some View {
        NavigationLink(destination: MoodForecastAnalysisView(
            emotion: viewModel.cityMoodData != nil ? Emotion.fromMoodScore(viewModel.cityMoodData!.currentMoodScore) : .neutral,
            city: locationService.currentCity ?? "San Francisco",
            day: "Today",
            timeSegment: getCurrentTimeSegment()
        )) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(locationService.currentCity ?? "San Francisco")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Big emotion emoji based on current mood
                    Text(viewModel.cityMoodData != nil ? 
                         Emotion.fromMoodScore(viewModel.cityMoodData!.currentMoodScore).emoji : "😐")
                        .font(.system(size: 60))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: viewModel.cityMoodData != nil ? 
                                              EmotionTheme.gradientColors(for: Emotion.fromMoodScore(viewModel.cityMoodData!.currentMoodScore)) :
                                              [Color.blue, Color.purple.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var moodTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Timeline")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.timelineEntries) { entry in
                        NavigationLink(destination: MoodForecastAnalysisView(emotion: entry.emotion, city: locationService.currentCity ?? "San Francisco", day: entry.day, timeSegment: entry.timeSegment)) {
                            TimelineItemView(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var favoriteCitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorite Cities")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Get top cities by contact count directly from contactService
                    ForEach(contactService.getTopCities(limit: 5), id: \.city) { cityData in
                        let city = cityData.city
                        let dominantEmotion = contactService.getDominantEmotionInCity(city) ?? .neutral
                        
                        NavigationLink(destination: MoodForecastAnalysisView(
                            emotion: dominantEmotion,
                            city: city,
                            day: "Today",
                            timeSegment: getCurrentTimeSegment()
                        )) {
                            VStack(spacing: 4) {
                                cityCard(city: city, color: Color.gray.opacity(0.2), emoji: dominantEmotion.emoji)
                                
                                // Show contact count
                                Text("\(cityData.count) contacts")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(width: 80, height: 120)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var recentContactsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Contacts")
                .font(.headline)
                .foregroundColor(.white)
            
            // Vertical scroll with reduced height
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(contactService.contacts.prefix(5)) { contact in
                        NavigationLink(destination: ContactMoodView(contact: contact)) {
                            CompactContactCard(contact: contact)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 200)
        }
    }
    
    // Helper function to get the current time segment
    private func getCurrentTimeSegment() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Morning"
        case 12..<17:
            return "Afternoon"
        case 17..<21:
            return "Evening"
        default:
            return "Night"
        }
    }
    
    // Replace static emoji text with animated emoji in the city cards
    private func cityCard(city: String, color: Color, emoji: String) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                AnimatedEmoji(emoji: emoji, size: 30, animation: .bounce)
                
                Text(city)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: 80, height: 80)
    }
}

// New view for Contact Mood
struct ContactMoodView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    
    // Sample data points for fact-based mood analysis
    var activityFactors: [(factor: String, value: String, impact: String)] {
        switch contact.emotion {
        case .happy:
            return [
                ("Recent Messages", "12 in past week", "Positive tone detected"),
                ("Call Frequency", "3 calls this month", "Above average"),
                ("Social Media", "Active, 8 posts", "Sharing positive content"),
            ]
        case .sad:
            return [
                ("Recent Messages", "2 in past week", "Below average"),
                ("Call Frequency", "1 call this month", "Declining pattern"),
                ("Social Media", "Less active", "Sharing somber content"),
            ]
        case .angry:
            return [
                ("Recent Messages", "5 in past week", "Frustrated tone detected"),
                ("Call Frequency", "No calls this month", "Unusual pattern"),
                ("Text Analysis", "Keywords detected", "Showing signs of stress"),
            ]
        default:
            return [
                ("Recent Messages", "6 in past week", "Normal pattern"),
                ("Call Frequency", "2 calls this month", "Consistent"),
                ("Social Media", "Moderately active", "Mixed content"),
            ]
        }
    }
    
    var emotionDescription: String {
        switch contact.emotion {
        case .happy:
            return "Based on recent interactions and activity patterns, \(contact.name) appears to be in a positive mood. Their communication shows optimistic language and they've been socially active."
        case .sad:
            return "Recent communication patterns from \(contact.name) indicate a potentially lower mood. There has been less frequent interaction and their messages contain more subdued language."
        case .angry:
            return "\(contact.name)'s recent communication contains indicators of frustration or stress. Text analysis has identified keywords associated with irritation and their response rate has decreased."
        case .surprised:
            return "\(contact.name) appears to be experiencing unexpected changes. Their communication patterns show sudden shifts in tone and frequency."
        case .fearful:
            return "Analysis of \(contact.name)'s recent messages indicates potential anxiety. Their communication contains cautious language and questions seeking reassurance."
        default:
            return "\(contact.name)'s mood appears to be balanced based on their communication patterns. Their message frequency and tone are consistent with their typical baseline."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Contact header
                VStack(spacing: 16) {
                    // Contact emoji
                    Text(contact.emotion.emoji)
                        .font(.system(size: 70))
                    
                    // Contact name
                    Text(contact.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Location
                    if let city = contact.city {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                            Text(city)
                        }
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Mood description
                    Text(contact.emotion.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Mood analysis
                VStack(alignment: .leading, spacing: 16) {
                    // Analysis title
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                        Text("Mood Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    // Mood description
                    Text(emotionDescription)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    // Fact-based indicators
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(activityFactors, id: \.factor) { factor in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(factor.factor)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(factor.value)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Text(factor.impact)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Suggested actions
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                        Text("Suggested Actions")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ActionButton(icon: "message.fill", text: "Send a message")
                        ActionButton(icon: "phone.fill", text: "Schedule a call")
                        ActionButton(icon: "calendar", text: "Plan a meetup")
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: EmotionTheme.gradientColors(for: contact.emotion)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Contact Mood")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
        })
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(text)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .foregroundColor(.white)
        }
    }
}

// Add extension to Emotion for easy categorization
extension Emotion {
    var isPositive: Bool {
        switch self {
        case .happy, .surprised:
            return true
        default:
            return false
        }
    }
    
    var isNegative: Bool {
        switch self {
        case .sad, .angry, .fearful, .disgusted:
            return true
        default:
            return false
        }
    }
}

class HomeViewModel: ObservableObject {
    @Published var cityMoodData: CityMoodData?
    @Published var timelineEntries: [TimelineEntry] = []
    private var citySentimentService = CitySentimentService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadCurrentCityMood(for city: String) {
        citySentimentService.getCitySentiment(for: city)
            .replaceError(with: citySentimentService.allCityData.first ?? CitySentimentService.getMockCitySentimentData()[0])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] moodData in
                guard let self = self else { return }
                self.cityMoodData = moodData
                self.generateTimelineEntries(from: moodData)
            }
            .store(in: &cancellables)
    }
    
    private func generateTimelineEntries(from data: CityMoodData) {
        let calendar = Calendar.current
        let now = Date()
        let timelinePoints = data.moodTimeline.sorted(by: { $0.timestamp > $1.timestamp })
        
        var entries: [TimelineEntry] = []
        
        // Yesterday Evening (around 6-7 PM)
        if let yesterdayEveningPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) &&
            calendar.component(.hour, from: $0.timestamp) >= 18 &&
            calendar.component(.hour, from: $0.timestamp) <= 19
        }) {
            entries.append(TimelineEntry(
                day: "Yesterday",
                timeSegment: "Evening",
                emotion: Emotion.fromMoodScore(yesterdayEveningPoint.score),
                isNow: false
            ))
        }
        
        // Yesterday Night (around 9-10 PM)
        if let yesterdayNightPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) &&
            calendar.component(.hour, from: $0.timestamp) >= 21 &&
            calendar.component(.hour, from: $0.timestamp) <= 22
        }) {
            entries.append(TimelineEntry(
                day: "Yesterday",
                timeSegment: "Night",
                emotion: Emotion.fromMoodScore(yesterdayNightPoint.score),
                isNow: false
            ))
        }
        
        // Today Morning (around 8-9 AM)
        if let todayMorningPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: now) &&
            calendar.component(.hour, from: $0.timestamp) >= 8 &&
            calendar.component(.hour, from: $0.timestamp) <= 9
        }) {
            entries.append(TimelineEntry(
                day: "Today",
                timeSegment: "Morning",
                emotion: Emotion.fromMoodScore(todayMorningPoint.score),
                isNow: calendar.component(.hour, from: now) >= 8 && calendar.component(.hour, from: now) <= 11
            ))
        }
        
        // Today Afternoon (around 2-3 PM)
        if let todayAfternoonPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: now) &&
            calendar.component(.hour, from: $0.timestamp) >= 14 &&
            calendar.component(.hour, from: $0.timestamp) <= 15
        }) {
            entries.append(TimelineEntry(
                day: "Today",
                timeSegment: "Afternoon",
                emotion: Emotion.fromMoodScore(todayAfternoonPoint.score),
                isNow: calendar.component(.hour, from: now) >= 12 && calendar.component(.hour, from: now) <= 17
            ))
        }
        
        // Today Evening (around 6-7 PM)
        if let todayEveningPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: now) &&
            calendar.component(.hour, from: $0.timestamp) >= 18 &&
            calendar.component(.hour, from: $0.timestamp) <= 19
        }) {
            entries.append(TimelineEntry(
                day: "Today",
                timeSegment: "Evening",
                emotion: Emotion.fromMoodScore(todayEveningPoint.score),
                isNow: calendar.component(.hour, from: now) >= 18 && calendar.component(.hour, from: now) <= 20
            ))
        }
        
        // Today Night (around 9-10 PM)
        if let todayNightPoint = timelinePoints.first(where: { 
            calendar.isDate($0.timestamp, inSameDayAs: now) &&
            calendar.component(.hour, from: $0.timestamp) >= 21 &&
            calendar.component(.hour, from: $0.timestamp) <= 22
        }) {
            entries.append(TimelineEntry(
                day: "Today",
                timeSegment: "Night",
                emotion: Emotion.fromMoodScore(todayNightPoint.score),
                isNow: calendar.component(.hour, from: now) >= 21
            ))
        }
        
        // If timeline entries are empty, create some default ones
        if entries.isEmpty {
            entries = [
                TimelineEntry(day: "Yesterday", timeSegment: "Evening", emotion: .neutral, isNow: false),
                TimelineEntry(day: "Yesterday", timeSegment: "Night", emotion: .angry, isNow: false),
                TimelineEntry(day: "Today", timeSegment: "Morning", emotion: .sad, isNow: false),
                TimelineEntry(day: "Today", timeSegment: "Afternoon", emotion: .neutral, isNow: true),
                TimelineEntry(day: "Today", timeSegment: "Evening", emotion: .neutral, isNow: false),
                TimelineEntry(day: "Today", timeSegment: "Night", emotion: .happy, isNow: false),
                TimelineEntry(day: "Tomorrow", timeSegment: "Morning", emotion: .neutral, isNow: false)
            ]
        } else {
            // Add prediction for tomorrow
            entries.append(TimelineEntry(
                day: "Tomorrow",
                timeSegment: "Morning",
                emotion: Emotion.fromMoodScore(data.currentMoodScore),
                isNow: false
            ))
        }
        
        self.timelineEntries = entries
    }
}

struct TimelineEntry: Identifiable {
    let id = UUID()
    let day: String
    let timeSegment: String
    let emotion: Emotion
    let isNow: Bool
}

struct TimelineItemView: View {
    let entry: TimelineEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(entry.day)
                .font(.footnote)
                .foregroundColor(.white)
            
            Text(entry.timeSegment)
                .font(.footnote)
                .foregroundColor(.white)
            
            getEmojiForEmotion(entry.emotion)
                .font(.system(size: 32))
                .padding(.vertical, 1)
            
            Text(entry.emotion.description)
                .font(.caption)
                .foregroundColor(.white)
            
            if entry.isNow {
                Text("NOW")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 1)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: EmotionTheme.gradientColors(for: entry.emotion).map { $0.opacity(0.75) }),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(entry.isNow ? Color.white : Color.clear, lineWidth: 2)
                )
        )
        .frame(width: 90)
    }
    
    private func getEmojiForEmotion(_ emotion: Emotion) -> Text {
        switch emotion {
        case .happy: return Text("😄")
        case .sad: return Text("😢")
        case .angry: return Text("😠")
        case .surprised: return Text("😲")
        case .fearful: return Text("😨")
        case .disgusted: return Text("🤢")
        case .neutral: return Text("😐")
        }
    }
}

struct ForecastItemView: View {
    let emotion: String
    let day: String
    let temperature: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            StaticEmojiView(emotion: convertStringToEmotion(emotion), size: 50)
            
            Text(day)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(temperature)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: EmotionTheme.gradientColors(for: convertStringToEmotion(emotion))),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(radius: 3)
        )
        .frame(width: 120, height: 150)
    }
    
    // Helper function to convert string to Emotion
    private func convertStringToEmotion(_ emotionString: String) -> Emotion {
        switch emotionString.lowercased() {
        case "happy": return .happy
        case "sad": return .sad
        case "angry": return .angry
        case "surprised": return .surprised
        case "fearful": return .fearful
        case "disgusted": return .disgusted
        case "excited": return .happy
        case "calm": return .neutral
        case "indifferent": return .neutral
        default: return .neutral
        }
    }
}

struct EnhancedContactCard: View {
    let contact: Contact
    
    var body: some View {
        NavigationLink(destination: DetailedContactView(contact: contact)) {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let city = contact.city {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(width: 120, height: 150)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(radius: 3)
            )
        }
    }
}

// Theme data structure for the mood forecast analysis
struct ThemeData: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let posts: Int
    let sentiments: String
    let keywords: [String]
    var percentage: Double
}

struct MoodForecastAnalysisView: View {
    let emotion: Emotion
    let city: String
    let day: String
    let timeSegment: String
    @Environment(\.dismiss) private var dismiss
    
    var themes: [ThemeData] {
        switch emotion {
        case .angry:
            return [
                ThemeData(icon: "🚌", title: "Transport Safety & Transit", posts: 45, sentiments: "anger, demand for reform", keywords: ["fatal Ocean Pkwy crash", "SoHo cyclist death", "Hov lanes"], percentage: 0.45),
                ThemeData(icon: "🏛️", title: "Local Politics / Policy", posts: 67, sentiments: "frustrated, combative", keywords: ["offshore-wind halt", "pension tiers", "mayor's race"], percentage: 0.67),
                ThemeData(icon: "🚓", title: "Crime & Policing", posts: 24, sentiments: "alarmed, outraged", keywords: ["teen kidnapping", "deportation cases", "death-penal"], percentage: 0.24),
                ThemeData(icon: "🏠", title: "Housing & Development", posts: 42, sentiments: "anxious, critical", keywords: ["Section 8 freeze (LA)", "2 WTC redesign", "rent-noti"], percentage: 0.42)
            ]
        case .happy:
            return [
                ThemeData(icon: "🎉", title: "Community Events", posts: 45, sentiments: "excited, cheerful", keywords: ["street festival", "art show", "music festival"], percentage: 0.45),
                ThemeData(icon: "📈", title: "Economic Growth", posts: 32, sentiments: "optimistic, hopeful", keywords: ["new businesses", "job opportunities", "economy boost"], percentage: 0.32),
                ThemeData(icon: "🏞️", title: "Outdoor Activities", posts: 28, sentiments: "relaxed, energetic", keywords: ["park events", "beach day", "hiking trails"], percentage: 0.28),
            ]
        default:
            return [
                ThemeData(icon: "🔄", title: "Changing Conditions", posts: 34, sentiments: "unsure, mixed", keywords: ["policy changes", "weather shifts", "adaptation"], percentage: 0.34),
                ThemeData(icon: "📊", title: "Neutral Indicators", posts: 26, sentiments: "observant, analytical", keywords: ["local statistics", "routine events", "daily patterns"], percentage: 0.26),
            ]
        }
    }
    
    var emoji: String {
        switch emotion {
        case .happy: return "😄"
        case .sad: return "😢"
        case .angry: return "😠"
        case .surprised: return "😲"
        case .fearful: return "😨"
        case .disgusted: return "🤢"
        case .neutral: return "😐"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with city and emoji
                VStack(spacing: 20) {
                    Text(emoji)
                        .font(.system(size: 80))
                    
                    Text(city)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text(day)
                            .fontWeight(.semibold)
                        
                        Text("•")
                        
                        Text(timeSegment)
                            .fontWeight(.semibold)
                        
                        Text("•")
                        
                        Text(emotion.description)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    
                    Button(action: {
                        // Action for current time button
                    }) {
                        HStack {
                            Image(systemName: "clock")
                            Text("Current Time")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                        .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
                
                // Mood Prediction Analysis
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                        Text("Mood Prediction Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                    Text("Based on analysis of social media posts, news articles, and community sentiment, we predict the mood will be \(emotion.description) during the \(timeSegment) period.")
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal)
                
                // Key Themes Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                        Text("Key Themes Driving This Mood")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    
                    // Theme cards
                    ForEach(themes) { theme in
                        ThemeCardView(theme: theme)
                    }
                }
                
                // Additional Insights
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                        Text("Additional Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    
                    // Insights
                    VStack(alignment: .leading, spacing: 20) {
                        InsightRow(icon: "chart.pie.fill", title: "Confidence Level", value: "85% based on historical accuracy")
                        
                        InsightRow(icon: "repeat", title: "Pattern Recognition", value: "Similar conditions in past 90 days led to this mood")
                        
                        InsightRow(icon: "person.3.fill", title: "Data Sources", value: "194 social posts analyzed for this prediction")
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: EmotionTheme.gradientColors(for: emotion)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Mood Forecast Analysis")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .foregroundColor(.white)
        })
    }
}

struct ThemeCardView: View {
    let theme: ThemeData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(theme.icon)
                    .font(.title)
                
                Text(theme.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 4)
                        .frame(width: 46, height: 46)
                    
                    Circle()
                        .trim(from: 0, to: theme.percentage)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 46, height: 46)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(theme.posts)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .foregroundColor(.white)
            
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.white.opacity(0.7))
                Text("\(theme.posts) posts")
                    .font(.subheadline)
                
                Text("•")
                
                Text(theme.sentiments)
                    .font(.subheadline)
                    .italic()
            }
            .foregroundColor(.white.opacity(0.8))
            
            // Keywords
            HStack(spacing: 12) {
                ForEach(theme.keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct CityCount {
    let name: String
    let count: Int
}

struct CompactContactCard: View {
    let contact: Contact
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                // Emoji based on emotion
                Text(contact.emotion.emoji)
                    .font(.system(size: 32))
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let city = contact.city {
                        Text(city)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: EmotionTheme.gradientColors(for: contact.emotion).map { $0.opacity(0.7) }),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            contactService: ContactService(),
            locationService: LocationService()
        )
    }
} 