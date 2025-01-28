import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // MARK: - Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "zh-Hant"
    @StateObject private var authService = AuthenticationService.shared
    
    // MARK: - Body
    var body: some View {
        Group {
            if authService.isAuthenticated {
                mainView
            } else {
                WelcomeView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environment(\.locale, Locale(identifier: language))
        .alert(NSLocalizedString("auth.session_expired.title", comment: "Session expired title"),
               isPresented: $authService.shouldShowAuthAlert) {
            Button(NSLocalizedString("common.ok", comment: "OK button"), role: .cancel) {
                authService.shouldShowAuthAlert = false
            }
        } message: {
            Text(authService.error ?? NSLocalizedString("auth.session_expired.message", comment: "Session expired message"))
        }
        .onAppear {
            if authService.isAuthenticated {
                authService.validateSession()
            }
        }
    }
    
    // MARK: - Main View
    private var mainView: some View {
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
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
} 
