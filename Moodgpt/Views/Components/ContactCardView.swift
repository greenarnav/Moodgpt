import SwiftUI

struct ContactCardView: View {
    let contact: Contact
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with name and emoji
            HStack {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                StaticEmojiView(emotion: contact.emotion, size: 30)
            }
            .padding(.bottom, 4)
            
            // Contact details
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Phone number with international formatting
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        
                        FormattedPhoneNumber(phoneNumber: contact.phoneNumber)
                            .font(.subheadline)
                    }
                    
                    if let city = contact.city {
                        HStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text(city)
                                .font(.subheadline)
                        }
                    }
                    
                    // Display country if available
                    if let countryFlag = contact.countryFlag {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text(countryFlag)
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ContactListView: View {
    @ObservedObject var contactService: ContactService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(contactService.contacts) { contact in
                    NavigationLink(destination: DetailedContactView(contact: contact)) {
                        ContactCardView(contact: contact)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
} 