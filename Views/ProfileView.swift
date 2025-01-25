import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @State private var showingSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeader()
                    AchievementStats()
                    FunctionList()
                }
                .padding(.vertical)
            }
            .navigationTitle(NSLocalizedString("profile.title", comment: "Profile screen title"))
            .navigationBarItems(trailing: Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
            })
            .sheet(isPresented: $showingSettings) {
                SettingsView(isDarkMode: $isDarkMode)
            }
        }
    }
}

// MARK: - Profile Header View
private struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            // User Avatar
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            // Username
            Text(NSLocalizedString("profile.username", comment: "User's display name"))
                .font(.title2)
                .fontWeight(.bold)
            
            // User Signature
            Text(NSLocalizedString("profile.signature", comment: "User's personal signature"))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Streak Badge
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text(NSLocalizedString("profile.streak", comment: "User's focus streak"))
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(15)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Achievement Stats View
private struct AchievementStats: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(NSLocalizedString("profile.monthly_stats", comment: "Monthly statistics title"))
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(
                    value: "32",
                    title: NSLocalizedString("profile.focus_hours", comment: "Total focus hours"),
                    icon: "clock.fill",
                    color: .blue
                )
                StatItem(
                    value: "15",
                    title: NSLocalizedString("profile.completed_goals", comment: "Number of completed goals"),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                StatItem(
                    value: "28",
                    title: NSLocalizedString("profile.writing_days", comment: "Number of days with diary entries"),
                    icon: "pencil.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Function List View
private struct FunctionList: View {
    var body: some View {
        VStack(spacing: 15) {
            Group {
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.achievements", comment: "Achievements screen title")),
                    icon: "trophy.fill",
                    title: NSLocalizedString("profile.achievements", comment: "Achievements menu item"),
                    color: .orange
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.data", comment: "Data report screen title")),
                    icon: "chart.bar.fill",
                    title: NSLocalizedString("profile.data", comment: "Data report menu item"),
                    color: .blue
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.learning", comment: "Learning history screen title")),
                    icon: "book.fill",
                    title: NSLocalizedString("profile.learning", comment: "Learning history menu item"),
                    color: .green
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.privacy", comment: "Privacy settings screen title")),
                    icon: "lock.fill",
                    title: NSLocalizedString("profile.privacy", comment: "Privacy settings menu item"),
                    color: .gray
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.help", comment: "Help and feedback screen title")),
                    icon: "questionmark.circle.fill",
                    title: NSLocalizedString("profile.help", comment: "Help and feedback menu item"),
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Supporting Views
private struct StatItem: View {
    let value: String
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct FunctionLink<Destination: View>: View {
    let destination: Destination
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
        }
    }
}

// MARK: - Preview Provider
#Preview {
    ProfileView()
} 