import Foundation
import Contacts
import Combine
import SwiftUI

class ContactsService {
    static let shared = ContactsService()
    
    private let contactStore = CNContactStore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var contacts: [ContactModel] = []
    @Published var favoriteContacts: [ContactModel] = []
    @Published var moodSharingEnabled: Bool = false
    
    private init() {
        requestContactsAccess()
        loadFavoriteContacts()
        loadMoodSharingPreference()
    }
    
    // Request access to user's contacts
    private func requestContactsAccess() {
        contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
            guard let self = self else { return }
            
            if granted {
                self.fetchContacts()
            } else if let error = error {
                print("Failed to request contacts access: \(error.localizedDescription)")
            }
        }
    }
    
    // Fetch contacts from the device
    private func fetchContacts() {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        do {
            var fetchedContacts: [ContactModel] = []
            
            try contactStore.enumerateContacts(with: request) { contact, _ in
                // Convert CNContact to ContactModel
                let contactModel = ContactModel(
                    id: contact.identifier,
                    firstName: contact.givenName,
                    lastName: contact.familyName,
                    phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
                    emails: contact.emailAddresses.map { $0.value as String },
                    thumbnailImageData: contact.thumbnailImageData
                )
                
                fetchedContacts.append(contactModel)
            }
            
            DispatchQueue.main.async {
                self.contacts = fetchedContacts.sorted { $0.fullName < $1.fullName }
                self.updateFavoriteContacts()
            }
            
        } catch {
            print("Error fetching contacts: \(error.localizedDescription)")
        }
    }
    
    // Load favorite contacts from UserDefaults
    private func loadFavoriteContacts() {
        if let data = UserDefaults.standard.data(forKey: "favoriteContacts") {
            do {
                let decoder = JSONDecoder()
                let favoriteIDs = try decoder.decode([String].self, from: data)
                
                // We'll update the actual contacts once they're fetched
                DispatchQueue.main.async {
                    self.updateFavoriteContacts(with: favoriteIDs)
                }
            } catch {
                print("Error loading favorite contacts: \(error.localizedDescription)")
            }
        }
    }
    
    // Update favorite contacts based on IDs
    private func updateFavoriteContacts(with favoriteIDs: [String]? = nil) {
        let ids = favoriteIDs ?? favoriteContacts.map { $0.id }
        favoriteContacts = contacts.filter { ids.contains($0.id) }
    }
    
    // Save favorite contacts to UserDefaults
    private func saveFavoriteContacts() {
        do {
            let encoder = JSONEncoder()
            let favoriteIDs = favoriteContacts.map { $0.id }
            let data = try encoder.encode(favoriteIDs)
            UserDefaults.standard.set(data, forKey: "favoriteContacts")
        } catch {
            print("Error saving favorite contacts: \(error.localizedDescription)")
        }
    }
    
    // Load mood sharing preference
    private func loadMoodSharingPreference() {
        moodSharingEnabled = UserDefaults.standard.bool(forKey: "moodSharingEnabled")
    }
    
    // Save mood sharing preference
    private func saveMoodSharingPreference() {
        UserDefaults.standard.set(moodSharingEnabled, forKey: "moodSharingEnabled")
    }
    
    // Add a contact to favorites
    func addToFavorites(_ contact: ContactModel) {
        if !favoriteContacts.contains(where: { $0.id == contact.id }) {
            favoriteContacts.append(contact)
            saveFavoriteContacts()
        }
    }
    
    // Remove a contact from favorites
    func removeFromFavorites(_ contact: ContactModel) {
        favoriteContacts.removeAll { $0.id == contact.id }
        saveFavoriteContacts()
    }
    
    // Toggle mood sharing
    func toggleMoodSharing() {
        moodSharingEnabled.toggle()
        saveMoodSharingPreference()
    }
    
    // Share mood with a specific contact
    func shareMood(with contact: ContactModel, mood: Emotion, message: String? = nil) -> AnyPublisher<Bool, Error> {
        // This would typically connect to a backend API
        // For now, we'll simulate a successful share
        
        let customMessage = message ?? "I'm feeling \(mood.description.lowercased()) today."
        
        print("Sharing mood with \(contact.fullName): \(customMessage)")
        
        // Simulate API call with a delay
        return Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Simulate 90% success rate
                if Double.random(in: 0...1) < 0.9 {
                    promise(.success(true))
                } else {
                    promise(.failure(NSError(domain: "MoodSharing", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to share mood. Please try again."])))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Share mood with all favorite contacts
    func shareMoodWithFavorites(mood: Emotion, message: String? = nil) -> AnyPublisher<Int, Error> {
        guard !favoriteContacts.isEmpty else {
            return Fail(error: NSError(domain: "MoodSharing", code: 400, userInfo: [NSLocalizedDescriptionKey: "No favorite contacts to share with."]))
                .eraseToAnyPublisher()
        }
        
        // Share with each favorite contact and count successes
        let publishers = favoriteContacts.map { contact in
            shareMood(with: contact, mood: mood, message: message)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { results in
                results.filter { $0 }.count
            }
            .eraseToAnyPublisher()
    }
    
    // Search contacts by name
    func searchContacts(query: String) -> [ContactModel] {
        guard !query.isEmpty else { return contacts }
        
        let lowercasedQuery = query.lowercased()
        return contacts.filter {
            $0.fullName.lowercased().contains(lowercasedQuery) ||
            $0.firstName.lowercased().contains(lowercasedQuery) ||
            $0.lastName.lowercased().contains(lowercasedQuery)
        }
    }
}

// Model for contact information
struct ContactModel: Identifiable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let phoneNumbers: [String]
    let emails: [String]
    let thumbnailImageData: Data?
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "No Name"
        } else if firstName.isEmpty {
            return lastName
        } else if lastName.isEmpty {
            return firstName
        } else {
            return "\(firstName) \(lastName)"
        }
    }
    
    var initials: String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        
        return (firstInitial + lastInitial).uppercased()
    }
    
    var primaryPhoneNumber: String? {
        phoneNumbers.first
    }
    
    var primaryEmail: String? {
        emails.first
    }
    
    static func == (lhs: ContactModel, rhs: ContactModel) -> Bool {
        lhs.id == rhs.id
    }
}

// SwiftUI extension for contact avatar
extension ContactModel {
    func avatar(size: CGFloat) -> some View {
        if let thumbnailData = thumbnailImageData, let uiImage = UIImage(data: thumbnailData) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            )
        } else {
            return AnyView(
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    
                    Text(initials)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(width: size, height: size)
            )
        }
    }
} 