import SwiftUI
import Combine
import Charts

struct CityMoodView: View {
    @StateObject private var viewModel = CityMoodViewModel()
    @EnvironmentObject private var navigationState: NavigationState
    
    @State private var selectedCity: String?
    @State private var showingMoodDetails = false
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                
                // City selection
                citySelector
                
                // Mood timeline
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Current mood section
                        currentMoodSection
                        
                        // Timeline section
                        timelineSection
                        
                        // Factors section
                        factorsSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showingMoodDetails) {
            if let selectedCity = selectedCity {
                CityMoodDetailView(city: selectedCity)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navigationState.path.removeLast()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("City Moods")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.refreshData()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    // Header section
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How are cities feeling?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 8)
            
            Text("Explore city moods based on social sentiment")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    // City selector
    private var citySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.cities, id: \.self) { city in
                    CityButton(
                        city: city,
                        isSelected: viewModel.selectedCity == city,
                        action: {
                            withAnimation {
                                viewModel.selectCity(city)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Current mood section
    private var currentMoodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(viewModel.selectedCity) is feeling")
                .font(.headline)
            
            HStack(alignment: .center, spacing: 20) {
                // Animated emoji
                if let cityData = viewModel.selectedCityData {
                    EnhancedEmotionView(
                        emotion: Emotion.fromMoodScore(cityData.currentMoodScore),
                        size: 80
                    )
                } else {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if let cityData = viewModel.selectedCityData {
                        let emotion = Emotion.fromMoodScore(cityData.currentMoodScore)
                        
                        Text(emotion.description)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(emotion.color)
                        
                        Text("Last updated: \(viewModel.lastUpdatedFormatted)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Loading...")
                            .font(.title)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                        
                        Text("Last updated: Just now")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .redacted(reason: .placeholder)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            
            Button {
                selectedCity = viewModel.selectedCity
                showingMoodDetails = true
            } label: {
                Text("View details")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    // Timeline section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("24-Hour Mood Timeline")
                .font(.headline)
            
            if let cityData = viewModel.selectedCityData, !cityData.moodTimeline.isEmpty {
                Chart {
                    ForEach(cityData.moodTimeline) { dataPoint in
                        LineMark(
                            x: .value("Time", dataPoint.timestamp),
                            y: .value("Mood", dataPoint.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.accentColor.gradient)
                        
                        AreaMark(
                            x: .value("Time", dataPoint.timestamp),
                            y: .value("Mood", dataPoint.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.01)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYScale(domain: 0...1)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            if hour % 4 == 0 {
                                AxisValueLabel {
                                    Text(date, format: .dateTime.hour())
                                }
                                AxisTick()
                                AxisGridLine()
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 0.25, 0.5, 0.75, 1]) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                let emotion = Emotion.fromMoodScore(val)
                                Text(emotion.description)
                                    .font(.caption)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: 200)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(height: 200)
                    .overlay {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("No timeline data available")
                                .foregroundColor(.secondary)
                        }
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    // Factors section
    private var factorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Factors Influencing \(viewModel.selectedCity)'s Mood")
                .font(.headline)
            
            if let cityData = viewModel.selectedCityData, !cityData.themes.isEmpty {
                ForEach(cityData.themes) { theme in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(theme.impact > 0.5 ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(theme.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(theme.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(theme.impact > 0.5 ? "+\(Int((theme.impact - 0.5) * 200))%" : "-\(Int((0.5 - theme.impact) * 200))%")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(theme.impact > 0.5 ? .green : .red)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 8)
                }
            } else {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Theme name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Theme description")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("+20%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                    .redacted(reason: .placeholder)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// City button component
struct CityButton: View {
    let city: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(city)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// City mood detail view
struct CityMoodDetailView: View {
    let city: String
    @StateObject private var viewModel = CityMoodDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Detailed mood breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mood Analysis")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            EnhancedEmotionView(
                                emotion: viewModel.cityEmotion,
                                size: 100
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.cityEmotion.description)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Overall sentiment score: \(Int(viewModel.moodScore * 100))%")
                                    .font(.subheadline)
                                
                                Text("Based on social media and news analysis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // Key themes chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Themes Driving Mood")
                            .font(.headline)
                        
                        if !viewModel.themes.isEmpty {
                            Chart {
                                ForEach(viewModel.themes) { theme in
                                    SectorMark(
                                        angle: .value("Impact", abs(theme.impact - 0.5) * 2),
                                        innerRadius: .ratio(0.618),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(4)
                                    .foregroundStyle(by: .value("Theme", theme.name))
                                }
                            }
                            .chartForegroundStyleScale(range: [.blue, .purple, .orange, .green, .red, .yellow])
                            .frame(height: 200)
                            
                            // Legend
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.themes) { theme in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(themeColor(for: theme))
                                            .frame(width: 10, height: 10)
                                        
                                        Text(theme.name)
                                            .font(.caption)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(abs(theme.impact - 0.5) * 200))%")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text("No theme data available")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // Social sentiment section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Social Sentiment")
                            .font(.headline)
                        
                        ForEach(viewModel.sentimentSamples) { sample in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(sample.sentiment > 0.5 ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sample.source)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(sample.text)
                                        .font(.subheadline)
                                    
                                    Text(sample.timestamp, format: .relative(presentation: .named))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
                .padding()
            }
            .navigationTitle("\(city) Mood Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadData(for: city)
            }
        }
    }
    
    // Get color for theme
    private func themeColor(for theme: MoodTheme) -> Color {
        let colors: [Color] = [.blue, .purple, .orange, .green, .red, .yellow]
        let index = abs(theme.name.hashValue) % colors.count
        return colors[index]
    }
}

class CityMoodViewModel: ObservableObject {
    @Published var cities: [String] = []
    @Published var selectedCity: String = "San Francisco"
    @Published var selectedCityData: CityMoodData?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    private let citySentimentService = CitySentimentService.shared
    
    var lastUpdatedFormatted: String {
        guard let timestamp = selectedCityData?.timestamp else {
            return "Just now"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for city data updates
        citySentimentService.$allCityData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cityData in
                guard let self = self else { return }
                
                // Extract city names
                self.cities = cityData.map { $0.city }
                
                // Update selected city data
                if let data = cityData.first(where: { $0.city == self.selectedCity }) {
                    self.selectedCityData = data
                } else if let firstCity = cityData.first {
                    // Default to first city if selected not found
                    self.selectedCity = firstCity.city
                    self.selectedCityData = firstCity
                }
                
                self.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func loadData() {
        isLoading = true
        citySentimentService.getAllCitySentiments()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                    self?.isLoading = false
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func refreshData() {
        isLoading = true
        citySentimentService.refreshData()
    }
    
    func selectCity(_ city: String) {
        selectedCity = city
        selectedCityData = citySentimentService.allCityData.first(where: { $0.city == city })
    }
}

class CityMoodDetailViewModel: ObservableObject {
    @Published var cityData: CityMoodData?
    @Published var themes: [MoodTheme] = []
    @Published var sentimentSamples: [SentimentSample] = []
    @Published var isLoading: Bool = false
    
    var cityEmotion: Emotion {
        guard let cityData = cityData else { return .neutral }
        return Emotion.fromMoodScore(cityData.currentMoodScore)
    }
    
    var moodScore: Double {
        cityData?.currentMoodScore ?? 0.5
    }
    
    func loadData(for city: String) {
        isLoading = true
        
        // In a real app, we would fetch this from the API
        // For now, use mock data
        let mockData = CitySentimentService.getMockCitySentimentData()
        if let cityData = mockData.first(where: { $0.city == city }) {
            self.cityData = cityData
            self.themes = cityData.themes
            
            // Generate some sample sentiment data
            self.sentimentSamples = generateMockSentimentSamples()
        }
        
        isLoading = false
    }
    
    private func generateMockSentimentSamples() -> [SentimentSample] {
        // Generate realistic mock sentiment samples based on city
        let sources = ["Twitter", "News", "Instagram", "Reddit", "Blog"]
        let sentiments = [0.2, 0.4, 0.6, 0.8, 0.9]
        
        var samples: [SentimentSample] = []
        
        for i in 0..<5 {
            let sample = SentimentSample(
                id: UUID(),
                source: sources[i % sources.count],
                text: generateSampleText(for: i),
                sentiment: sentiments[i % sentiments.count],
                timestamp: Date().addingTimeInterval(-Double((i + 1) * 3600))
            )
            samples.append(sample)
        }
        
        return samples
    }
    
    private func generateSampleText(for index: Int) -> String {
        let texts = [
            "The local transit system has been much more reliable lately, making commuting a breeze!",
            "Traffic is terrible today, especially downtown. Avoid if possible.",
            "Weather is absolutely perfect for outdoor activities this weekend!",
            "New housing developments are causing concerns about neighborhood character and affordability.",
            "The food festival downtown was amazing! So many great local vendors."
        ]
        
        return texts[index % texts.count]
    }
}

// Model for sentiment samples
struct SentimentSample: Identifiable {
    var id: UUID
    let source: String
    let text: String
    let sentiment: Double
    let timestamp: Date
} 