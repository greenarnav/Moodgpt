import SwiftUI
import Combine

struct EmotionDetailView: View {
    let contact: Contact
    
    @State private var emotionDetails: EmotionDetails?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.dismiss) private var dismiss
    
    // Default initializer
    init(contact: Contact) {
        self.contact = contact
    }
    
    var body: some View {
        ZStack {
            // Background gradient based on contact's primary emotion
            if let details = emotionDetails {
                LinearGradient(
                    gradient: Gradient(colors: [details.primaryEmotion.color.opacity(0.7), details.primaryEmotion.color.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                Color.gray.opacity(0.2).ignoresSafeArea()
            }
            
            if isLoading {
                loadingView
            } else if let details = emotionDetails {
                ScrollView {
                    VStack(spacing: 24) {
                        headerView(details: details)
                        emotionIntensityView(details: details)
                        secondaryEmotionsView(details: details)
                        triggersView(details: details)
                        moodHistoryView(details: details)
                    }
                    .padding()
                }
            } else if error != nil {
                errorView
            }
        }
        .navigationTitle("Emotion Details")
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
                Text("\(contact.name)'s Emotions")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            fetchEmotionDetails()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Analyzing emotional patterns...")
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.white)
            
            Text("Failed to load emotion data")
                .font(.headline)
                .foregroundColor(.white)
            
            Button("Try Again") {
                isLoading = true
                fetchEmotionDetails()
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
    }
    
    private func headerView(details: EmotionDetails) -> some View {
        VStack(spacing: 16) {
            StaticEmojiView(emotion: details.primaryEmotion, size: 100)
                .shadow(color: .black.opacity(0.2), radius: 5)
            
            Text(details.primaryEmotion.description)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Text("Primary Emotion")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Last updated \(formatTimestamp(details.timestamp))")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func emotionIntensityView(details: EmotionDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Emotion Intensity")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(details.emotionIntensity * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    intensityIcon(intensity: details.emotionIntensity)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress
                        Rectangle()
                            .fill(details.primaryEmotion.color)
                            .frame(width: geometry.size.width * CGFloat(details.emotionIntensity), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                Text(intensityDescription(intensity: details.emotionIntensity))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func secondaryEmotionsView(details: EmotionDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Secondary Emotions")
                .font(.headline)
                .foregroundColor(.white)
            
            if details.secondaryEmotions.isEmpty {
                Text("No secondary emotions detected")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            } else {
                HStack(spacing: 16) {
                    ForEach(details.secondaryEmotions, id: \.self) { emotion in
                        VStack(spacing: 8) {
                            StaticEmojiView(emotion: emotion, size: 44)
                            
                            Text(emotion.description)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(emotion.color.opacity(0.2))
                        .cornerRadius(12)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func triggersView(details: EmotionDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Triggers")
                .font(.headline)
                .foregroundColor(.white)
            
            if details.moodTriggers.isEmpty {
                Text("No triggers detected")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(details.moodTriggers, id: \.self) { trigger in
                        HStack(alignment: .top) {
                            Image(systemName: "arrow.up.right")
                                .font(.footnote)
                                .foregroundColor(details.primaryEmotion.color)
                                .frame(width: 20)
                            
                            Text(trigger)
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
    
    private func moodHistoryView(details: EmotionDetails) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Changes")
                .font(.headline)
                .foregroundColor(.white)
            
            if details.recentMoodChanges.isEmpty {
                Text("No recent mood changes")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(details.recentMoodChanges) { change in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                StaticEmojiView(emotion: change.fromEmotion, size: 24)
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                                
                                StaticEmojiView(emotion: change.toEmotion, size: 24)
                                
                                Spacer()
                                
                                Text(formatTimestamp(change.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            if let reason = change.reason {
                                Text(reason)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 4)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    // Helper functions
    private func intensityIcon(intensity: Double) -> some View {
        let iconName: String
        let color: Color
        
        switch intensity {
        case 0..<0.25:
            iconName = "thermometer.low"
            color = .blue
        case 0.25..<0.5:
            iconName = "thermometer.medium"
            color = .yellow
        case 0.5..<0.75:
            iconName = "thermometer.medium.fill"
            color = .orange
        default:
            iconName = "thermometer.high"
            color = .red
        }
        
        return Image(systemName: iconName)
            .foregroundColor(color)
            .font(.system(size: 22))
    }
    
    private func intensityDescription(intensity: Double) -> String {
        switch intensity {
        case 0..<0.25:
            return "Mild emotional response"
        case 0.25..<0.5:
            return "Moderate emotional response"
        case 0.5..<0.75:
            return "Strong emotional response"
        default:
            return "Very intense emotional response"
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func fetchEmotionDetails() {
        EmotionAPI.shared.fetchDetailedEmotions(for: contact.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let err):
                        self.error = err
                        self.isLoading = false
                    }
                },
                receiveValue: { details in
                    self.emotionDetails = details
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
} 