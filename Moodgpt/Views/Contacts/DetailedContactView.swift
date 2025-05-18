import SwiftUI

struct DetailedContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contact: Contact
    @State private var showingInterestEditor = false
    @State private var selectedTab = 0
    @State private var navigateToEmotionDetail = false
    
    init(contact: Contact) {
        _contact = State(initialValue: contact)
    }
    
    var body: some View {
        ZStack {
            // Background gradient based on emotion
            LinearGradient(
                gradient: Gradient(colors: [contact.emotion.color.opacity(0.7), contact.emotion.color.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with emotion
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                        
                        Text(contact.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 10) {
                            StaticEmojiView(emotion: contact.emotion, size: 36)
                            
                            Text("Currently feeling \(contact.emotion.description)")
                                .font(.headline)
                                .foregroundColor(contact.emotion.color)
                        }
                        .padding(.vertical, 4)
                        
                        // Button to view detailed emotions
                        Button(action: {
                            navigateToEmotionDetail = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("View Detailed Emotions")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                        .padding(.top, 4)
                        
                        if let city = contact.city, !city.isEmpty {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.secondary)
                                Text("Located in \(city)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Tab selector
                    Picker("View", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Insights").tag(1)
                        Text("What to Say").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .colorMultiply(.white)
                    
                    // Tab content
                    VStack {
                        switch selectedTab {
                        case 0:
                            overviewTab
                        case 1:
                            insightsTab
                        case 2:
                            conversationTab
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            
            // Add details FAB
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingInterestEditor = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.blue))
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Contact Details")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingInterestEditor) {
            InterestEditorView(contact: $contact)
        }
        .background(
            NavigationLink(destination: EmotionDetailView(contact: contact), isActive: $navigateToEmotionDetail) {
                EmptyView()
            }
        )
    }
    
    // MARK: - Tab Views
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Contact information
            contactInfoSection
            
            // Mood description
            moodDescriptionSection
            
            // Interests
            interestsSection
        }
    }
    
    private var insightsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Facts and figures
            factsSection
            
            // Thoughts and feelings
            thoughtsSection
            
            // Recent activity
            recentActivitySection
        }
    }
    
    private var conversationTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Conversation starters
            conversationStartersSection
            
            // Communication tips
            communicationTipsSection
            
            // Quick actions
            quickActionsSection
        }
    }
    
    // MARK: - Section Components
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Contact Information")
            
            HStack(alignment: .center) {
                Image(systemName: "phone.fill")
                    .frame(width: 24)
                    .foregroundColor(.white.opacity(0.7))
                
                FormattedPhoneNumber(phoneNumber: contact.phoneNumber)
                    .foregroundColor(.white)
            }
            
            // Show country info if available
            if let countryInfo = getCountryInfo() {
                HStack {
                    Image(systemName: "globe")
                        .frame(width: 24)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(countryInfo)
                        .foregroundColor(.white)
                }
            }
            
            if let city = contact.city {
                HStack {
                    Image(systemName: "mappin.fill")
                        .frame(width: 24)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(city)
                        .foregroundColor(.white)
                }
            }
            
            if let notes = contact.notes {
                HStack(alignment: .top) {
                    Image(systemName: "note.text")
                        .frame(width: 24)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(notes)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // Helper to get country information based on phone number
    private func getCountryInfo() -> String? {
        let (countryCode, _) = PhoneNumberHelper.extractCountryCode(from: contact.phoneNumber)
        
        if let (flag, _) = PhoneNumberHelper.countryCodes[countryCode] {
            let countryName = getCountryName(for: countryCode)
            return "\(flag) \(countryName)"
        }
        return nil
    }
    
    // Map country code to country name
    private func getCountryName(for countryCode: String) -> String {
        switch countryCode {
        case "1": return "United States/Canada"
        case "44": return "United Kingdom"
        case "91": return "India"
        case "86": return "China"
        case "49": return "Germany"
        case "33": return "France"
        case "61": return "Australia"
        case "81": return "Japan"
        case "7": return "Russia"
        case "55": return "Brazil"
        case "82": return "South Korea"
        case "39": return "Italy"
        case "34": return "Spain"
        case "52": return "Mexico"
        case "31": return "Netherlands"
        case "90": return "Turkey"
        case "966": return "Saudi Arabia"
        case "65": return "Singapore"
        case "971": return "United Arab Emirates"
        case "27": return "South Africa"
        default: return "International"
        }
    }
    
    private var moodDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Current Mood")
            
            Text(contact.getEmotionDescription())
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Interests")
            
            if contact.interests.isEmpty {
                Text("No interests added yet. Tap the + button to add some!")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(contact.interests, id: \.self) { interest in
                            HStack {
                                Image(systemName: "star.fill") // Default icon for string-based interests
                                    .font(.subheadline)
                                
                                Text(interest)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var factsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Facts & Figures")
            
            if let facts = contact.factsAndFigures {
                Text(facts)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            } else {
                Text("No facts added yet. Tap the + button to add information.")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var thoughtsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Thoughts & Feelings")
            
            if let thoughts = contact.thoughtsAndFeelings {
                Text(thoughts)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            } else {
                Text("No thoughts recorded yet. Tap the + button to add information.")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Recent Activity")
            
            // Sample activity for demo
            VStack(alignment: .leading, spacing: 10) {
                ActivityRowView(
                    icon: "arrow.up.right.circle.fill",
                    color: .green,
                    title: "Mood improved",
                    subtitle: "Changed from Neutral to \(contact.emotion.rawValue.capitalized)",
                    time: "2 hours ago"
                )
                
                ActivityRowView(
                    icon: "mappin.circle.fill",
                    color: .blue,
                    title: "Changed location",
                    subtitle: "Now in \(contact.city ?? "Unknown")",
                    time: "Yesterday"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var conversationStartersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Conversation Starters")
            
            let starters = contact.getConversationStarters()
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(starters, id: \.self) { starter in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text(starter)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var communicationTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Communication Tips")
            
            let tips = getCommunicationTips()
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.footnote)
                            .frame(width: 24, alignment: .center)
                        
                        Text(tip)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Quick Actions")
            
            HStack(spacing: 20) {
                // Call button
                VStack {
                    Button(action: {
                        // In a real app, implement call functionality
                    }) {
                        VStack {
                            Image(systemName: "phone.fill")
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)
                            
                            Text("Call")
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    }
                }
                
                // Message button
                VStack {
                    Button(action: {
                        // In a real app, implement message functionality
                    }) {
                        VStack {
                            Image(systemName: "message.fill")
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.green))
                                .foregroundColor(.white)
                            
                            Text("Message")
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    }
                }
                
                // Video button
                VStack {
                    Button(action: {
                        // In a real app, implement video call functionality
                    }) {
                        VStack {
                            Image(systemName: "video.fill")
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.purple))
                                .foregroundColor(.white)
                            
                            Text("Video")
                                .foregroundColor(.white)
                                .font(.footnote)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Functions
    
    private func getCommunicationTips() -> [String] {
        switch contact.emotion {
        case .happy:
            return [
                "Celebrate their positive mood by sharing in their enthusiasm",
                "Ask open-ended questions about what's going well for them",
                "This is a good time to discuss future plans or collaborate on ideas"
            ]
        case .sad:
            return [
                "Give them space to express their feelings without rushing to fix things",
                "Use a gentle, supportive tone in your messages",
                "Acknowledge their feelings without minimizing them"
            ]
        case .angry:
            return [
                "Allow them to vent if needed, but don't escalate the situation",
                "Keep messages concise and clear to avoid misunderstandings",
                "Consider giving them space if the anger seems intense"
            ]
        case .surprised:
            return [
                "Be supportive as they process unexpected news or changes",
                "Listen attentively as they share what surprised them",
                "Help them make sense of their new situation if appropriate"
            ]
        case .fearful:
            return [
                "Offer reassurance without dismissing their concerns",
                "Help them focus on what they can control",
                "Check in regularly without being overbearing"
            ]
        case .disgusted:
            return [
                "Validate their feelings without necessarily agreeing",
                "Give them space to process their reactions",
                "Focus on common ground in your conversations"
            ]
        case .neutral:
            return [
                "Keep conversation light and engaging",
                "This is a good time to introduce new topics or ideas",
                "Ask about their interests and follow up on previous conversations"
            ]
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct ActivityRowView: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let time: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

struct InterestEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var contact: Contact
    @State private var selectedInterests: [String] = []
    @State private var newThoughts: String = ""
    @State private var newFacts: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Interests selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What interests \(contact.name)?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Interest.all) { interest in
                                    InterestSelectionButton(
                                        interest: interest,
                                        isSelected: isInterestSelected(interest.name)
                                    ) {
                                        toggleInterest(interest.name)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Thoughts and feelings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Thoughts & Feelings")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $newThoughts)
                                .padding()
                                .frame(minHeight: 100)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .overlay(
                                    Group {
                                        if newThoughts.isEmpty {
                                            Text("What are they thinking or feeling?")
                                                .foregroundColor(.white.opacity(0.4))
                                                .padding()
                                                .allowsHitTesting(false)
                                        }
                                    }
                                )
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Facts and figures
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Facts & Figures")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $newFacts)
                                .padding()
                                .frame(minHeight: 100)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .overlay(
                                    Group {
                                        if newFacts.isEmpty {
                                            Text("Important information about \(contact.name)")
                                                .foregroundColor(.white.opacity(0.4))
                                                .padding()
                                                .allowsHitTesting(false)
                                        }
                                    }
                                )
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Add Contact Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button("Save") {
                    saveChanges()
                    dismiss()
                }
                .foregroundColor(.blue)
            )
            .onAppear {
                // Initialize with existing data
                selectedInterests = contact.interests
                newThoughts = contact.thoughtsAndFeelings ?? ""
                newFacts = contact.factsAndFigures ?? ""
            }
        }
    }
    
    private func isInterestSelected(_ interestName: String) -> Bool {
        return selectedInterests.contains(interestName)
    }
    
    private func toggleInterest(_ interestName: String) {
        if let index = selectedInterests.firstIndex(of: interestName) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interestName)
        }
    }
    
    private func saveChanges() {
        contact.interests = selectedInterests
        contact.thoughtsAndFeelings = newThoughts.isEmpty ? nil : newThoughts
        contact.factsAndFigures = newFacts.isEmpty ? nil : newFacts
    }
}

struct InterestSelectionButton: View {
    let interest: Interest
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: interest.icon)
                    .font(.subheadline)
                
                Text(interest.name)
                    .font(.subheadline)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .foregroundColor(.white)
    }
}

struct FilterOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(isSelected ? .bold : .regular)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .foregroundColor(.white)
    }
}

// Define the EmotionHistory type
struct EmotionHistory: Identifiable {
    let id = UUID()
    let emotion: Emotion
    let date: Date
}

struct EmotionHistorySection: View {
    let history: [EmotionHistory]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood History")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(history) { history in
                        VStack(spacing: 8) {
                            StaticEmojiView(emotion: history.emotion, size: 44)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                            
                            Text(history.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(history.emotion.color.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
} 