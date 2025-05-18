import SwiftUI
import Combine

struct HomeView: View {
    @ObservedObject var contactService: ContactService
    @ObservedObject var locationService: LocationService
    @StateObject private var viewModel = HomeViewModel()
    @State private var mockedContacts: [Contact] = [
        Contact(name: "John Smith", phoneNumber: "+1 555-123-4567", city: "San Francisco", emotion: .happy),
        Contact(name: "Amy Lee", phoneNumber: "+1 555-987-6543", city: "New York", emotion: .surprised),
        Contact(name: "Mike Taylor", phoneNumber: "+1 555-456-7890", city: "Chicago", emotion: .neutral),
        Contact(name: "Sarah Johnson", phoneNumber: "+1 555-234-5678", city: "New York", emotion: .happy),
        Contact(name: "David Brown", phoneNumber: "+1 555-876-5432", city: "San Francisco", emotion: .sad),
        Contact(name: "Emily Wilson", phoneNumber: "+1 555-345-6789", city: "Boston", emotion: .fearful),
        Contact(name: "Michael Chen", phoneNumber: "+1 555-654-3210", city: "New York", emotion: .angry),
        Contact(name: "Jessica Martinez", phoneNumber: "+1 555-789-0123", city: "Los Angeles", emotion: .happy)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        currentLocationCard
                        
                        moodTimelineSection
                        
                        favoriteCitiesSection
                        
                        recentContactsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                locationService.requestAuthorization()
                viewModel.loadCurrentCityMood(for: locationService.currentCity ?? "San Francisco")
            }
        }
    }
    
    private var currentLocationCard: some View {
        NavigationLink(destination: MoodForecastAnalysisView(
            emotion: viewModel.cityMoodData != nil ? Emotion.fromMoodScore(viewModel.cityMoodData!.currentMoodScore) : .neutral,
            city: locationService.currentCity ?? "San Francisco",
            day: "Today",
            timeSegment: getCurrentTimeSegment()
        )) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Location")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(locationService.currentCity ?? "San Francisco")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Use AnimatedEmoji with pulse effect for current location
                    AnimatedEmoji(emoji: "📍", size: 32, animation: .pulse)
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
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(getTopCities(), id: \.name) { city in
                        let dominantEmotion = getDominantEmotion(for: city.name)
                        NavigationLink(destination: MoodForecastAnalysisView(
                            emotion: dominantEmotion,
                            city: city.name,
                            day: "Today",
                            timeSegment: getCurrentTimeSegment()
                        )) {
                            VStack(spacing: 4) {
                                cityCard(city: city.name, color: Color.gray.opacity(0.2), emoji: getDominantEmotionEmoji(for: city.name))
                            }
                            .frame(width: 70, height: 100)
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
                    ForEach(mockedContacts.prefix(5)) { contact in
                        NavigationLink(destination: DetailedContactView(contact: contact)) {
                            CompactContactCard(contact: contact)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 200)
        }
    }
    
    private func getTopCities() -> [CityCount] {
        // Group contacts by city and count them
        var cityCountDict: [String: Int] = [:]
        
        for contact in mockedContacts {
            if let city = contact.city {
                cityCountDict[city, default: 0] += 1
            }
        }
        
        // Convert to array and sort
        let sortedCities = cityCountDict.map { CityCount(name: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
        
        return sortedCities.prefix(5).map { $0 }
    }
    
    private func getDominantEmotionEmoji(for city: String) -> String {
        let dominantEmotion = getDominantEmotion(for: city)
        return dominantEmotion.emoji
    }
    
    private func getAnimationForCity(city: String) -> AnimatedEmoji.EmojiAnimation {
        let dominantEmotion = getDominantEmotion(for: city)
        return dominantEmotion.animation
    }
    
    private func getEmojiForEmotion(_ emotion: Emotion) -> String {
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
    
    // Add a function to get the dominant emotion for a city
    private func getDominantEmotion(for city: String) -> Emotion {
        let cityContacts = mockedContacts.filter { $0.city == city }
        var emotionCount: [Emotion: Int] = [:]
        
        // Count occurrences of each emotion
        for contact in cityContacts {
            emotionCount[contact.emotion, default: 0] += 1
        }
        
        // Return the most common emotion or neutral if none found
        return emotionCount.max(by: { $0.value < $1.value })?.key ?? .neutral
    }
    
    // Replace static emoji text with animated emoji in the city cards
    private func cityCard(city: String, color: Color, emoji: String) -> some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 80, height: 80)
            
            VStack(spacing: 4) {
                AnimatedEmoji(emoji: emoji, size: 30, animation: getAnimationForCity(city: city))
                
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
                Text(getEmojiForEmotion(contact.emotion))
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
    
    private func getEmojiForEmotion(_ emotion: Emotion) -> String {
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
                        gradient: Gradient(colors: EmotionTheme.gradientColors(for: emotion)),
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            contactService: ContactService(),
            locationService: LocationService()
        )
    }
} 