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
            .navigationTitle(NSLocalizedString("profile.title", comment: ""))
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

// MARK: - Profile Header
private struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text(NSLocalizedString("profile.username", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("profile.signature", comment: ""))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text(NSLocalizedString("profile.streak", comment: ""))
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

// MARK: - Achievement Stats
private struct AchievementStats: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(NSLocalizedString("profile.monthly_stats", comment: ""))
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(
                    value: "32",
                    title: NSLocalizedString("profile.focus_hours", comment: ""),
                    icon: "clock.fill",
                    color: .blue
                )
                StatItem(
                    value: "15",
                    title: NSLocalizedString("profile.completed_goals", comment: ""),
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                StatItem(
                    value: "28",
                    title: NSLocalizedString("profile.writing_days", comment: ""),
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

// MARK: - Function List
private struct FunctionList: View {
    var body: some View {
        VStack(spacing: 15) {
            Group {
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.achievements", comment: "")),
                    icon: "trophy.fill",
                    title: NSLocalizedString("profile.achievements", comment: ""),
                    color: .orange
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.data", comment: "")),
                    icon: "chart.bar.fill",
                    title: NSLocalizedString("profile.data", comment: ""),
                    color: .blue
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.learning", comment: "")),
                    icon: "book.fill",
                    title: NSLocalizedString("profile.learning", comment: ""),
                    color: .green
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.privacy", comment: "")),
                    icon: "lock.fill",
                    title: NSLocalizedString("profile.privacy", comment: ""),
                    color: .gray
                )
                
                FunctionLink(
                    destination: Text(NSLocalizedString("profile.help", comment: "")),
                    icon: "questionmark.circle.fill",
                    title: NSLocalizedString("profile.help", comment: ""),
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

#Preview {
    ProfileView()
} 