import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // MARK: - Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "zh-Hant"
    
    // MARK: - Body
    var body: some View {
        TabView {
            FocusView()
                .tabItem {
                    Label(NSLocalizedString("tab.focus", comment: "Focus tab"), systemImage: "timer")
                }
            
            DiaryView()
                .tabItem {
                    Label(NSLocalizedString("tab.diary", comment: "Diary tab"), systemImage: "book")
                }
            
            GroupView()
                .tabItem {
                    Label(NSLocalizedString("tab.group", comment: "Group tab"), systemImage: "person.3")
                }
            
            GoalsView()
                .tabItem {
                    Label(NSLocalizedString("tab.goals", comment: "Goals tab"), systemImage: "flag")
                }
            
            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab.profile", comment: "Profile tab"), systemImage: "person")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environment(\.locale, Locale(identifier: language))
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
} 