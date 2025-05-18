import SwiftUI
import Combine

struct ContactsView: View {
    @ObservedObject var contactService: ContactService
    @State private var searchText = ""
    @State private var selectedFilter: Emotion? = nil
    @State private var selectedContact: Contact? = nil
    @State private var showingAddContact = false
    
    private var filteredContacts: [Contact] {
        var filtered = contactService.contacts
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.city?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if let filter = selectedFilter {
            filtered = filtered.filter { $0.emotion == filter }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterButton(nil, "All")
                    
                    ForEach(Emotion.allCases) { emotion in
                        filterButton(emotion, emotion.description)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            if contactService.contacts.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Contacts Found")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your contacts will appear here once you add them.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        showingAddContact = true
                    }) {
                        Text("Add Contact")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            } else {
                List {
                    ForEach(filteredContacts) { contact in
                        NavigationLink(destination: contactDestination(for: contact)) {
                            ContactListItem(contact: contact)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Contacts")
        .navigationBarItems(trailing:
            Button(action: {
                showingAddContact = true
            }) {
                Image(systemName: "plus")
                    .font(.title3)
            }
        )
        .sheet(isPresented: $showingAddContact) {
            AddContactView(contactService: contactService)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search contacts", text: $searchText)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func filterButton(_ emotion: Emotion?, _ title: String) -> some View {
        Button(action: {
            withAnimation {
                selectedFilter = emotion
            }
        }) {
            HStack {
                if let emotion = emotion {
                    StaticEmojiView(emotion: emotion, size: 20)
                        .padding(.trailing, 4)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(selectedFilter == emotion ? .bold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedFilter == emotion ?
                          (emotion?.color ?? Color.blue).opacity(0.2) :
                          Color(.systemGray6))
            )
            .foregroundColor(selectedFilter == emotion ?
                             (emotion?.color ?? Color.blue) :
                             Color.primary)
        }
    }
    
    @ViewBuilder
    private func contactDestination(for contact: Contact) -> some View {
        if contact.emotion == .happy || contact.emotion == .sad {
            // For happy and sad emotions, show the detailed emotion view first
            EmotionDetailView(contact: contact)
        } else {
            // For other emotions, show the regular contact detail view
            DetailedContactView(contact: contact)
        }
    }
}

struct ContactListItem: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                FormattedPhoneNumber(phoneNumber: contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let city = contact.city {
                    Text(city)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Text("Mood:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(contact.emotion.description)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(contact.emotion.color)
                }
            }
            
            Spacer()
            
            StaticEmojiView(emotion: contact.emotion, size: 40)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .contentShape(Rectangle())
    }
} 