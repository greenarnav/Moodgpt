import Foundation
import SwiftUI

class NavigationState: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: AppTab = .home
    
    func navigateTo(_ destination: AppDestination) {
        path.append(destination)
    }
    
    func navigateToRoot() {
        path = NavigationPath()
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case maps
    case contacts
    case settings
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .maps: return "Maps"
        case .contacts: return "Contacts"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .maps: return "map.fill"
        case .contacts: return "person.2.fill"
        case .settings: return "gear"
        }
    }
}

enum AppDestination: Hashable {
    case cityMood
    case activityDetail(activityId: UUID)
    case moodTracking
    case settings
    case contacts
    case notifications
    case help
    case about
    
    var title: String {
        switch self {
        case .cityMood: return "City Mood"
        case .activityDetail: return "Activity Details"
        case .moodTracking: return "Mood Tracking"
        case .settings: return "Settings"
        case .contacts: return "Contacts"
        case .notifications: return "Notifications"
        case .help: return "Help"
        case .about: return "About"
        }
    }
} 