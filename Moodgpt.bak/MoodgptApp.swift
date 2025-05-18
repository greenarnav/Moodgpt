//
//  MoodgptApp.swift
//  Moodgpt
//
//  Created by Test on 5/17/25.
//

import SwiftUI

@main
struct MoodgptApp: App {
    @StateObject private var navigationState = NavigationState()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .environmentObject(navigationState)
                .onChange(of: hasCompletedOnboarding) { newValue in
                    if newValue {
                        // Make sure onboarding completion is saved
                        navigationState.completeOnboarding()
                        
                        // Force update the UI
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                }
            } else {
                MainTabView()
                    .environmentObject(navigationState)
                    .onAppear {
                        setupServices()
                    }
            }
        }
    }
    
    private func setupServices() {
        // Initialize services safely
        let _ = APIService.shared
        let _ = CitySentimentService.shared
        let _ = NotificationService.shared
        let _ = LocationTrackingService.shared
        let _ = ActivityTrackingService.shared
        let _ = ContactsService.shared
        
        // Safely set up notification categories without requesting permissions
        NotificationService.shared.setupNotificationCategories()
        
        // Mock notification setup instead of actually scheduling it
        if !UserDefaults.standard.bool(forKey: "initialNotificationSent") {
            print("Would schedule a notification in a real app")
            UserDefaults.standard.set(true, forKey: "initialNotificationSent")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var navigationState: NavigationState
    @StateObject private var contactService = ContactService()
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            // Home tab
            NavigationStack(path: $navigationState.path) {
                HomeView(contactService: contactService, locationService: locationService)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)
            
            // Maps tab
            NavigationStack(path: $navigationState.path) {
                MapView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Maps", systemImage: "map.fill")
            }
            .tag(AppTab.maps)
            
            // Contacts tab
            NavigationStack(path: $navigationState.path) {
                ContactsView(contactService: contactService)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Contacts", systemImage: "person.2.fill")
            }
            .tag(AppTab.contacts)
            
            // Settings tab
            NavigationStack(path: $navigationState.path) {
                SettingsView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppTab.settings)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .cityMood:
            CityMoodView()
        case .activityDetail(let activityId):
            Text("Activity Detail for \(activityId)")
        case .moodTracking:
            Text("Mood Tracking")
        case .settings:
            SettingsView()
        case .contacts:
            ContactsView(contactService: contactService)
        case .notifications:
            Text("Notifications")
        case .help:
            Text("Help")
        case .about:
            Text("About")
        }
    }
}

// These are placeholder views to be implemented later
struct MoodView: View {
    var body: some View {
        Text("Mood View")
            .font(.largeTitle)
    }
}

struct ActivitiesView: View {
    var body: some View {
        Text("Activities View")
            .font(.largeTitle)
    }
}

struct CitiesView: View {
    @EnvironmentObject private var navigationState: NavigationState
    
    var body: some View {
        VStack {
            Text("Cities View")
                .font(.largeTitle)
            
            Button("Go to City Mood") {
                navigationState.navigateTo(.cityMood)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
            .font(.largeTitle)
    }
}
