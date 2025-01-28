import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // MARK: - Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "zh-Hant"
    @StateObject private var authService = AuthenticationService.shared
    @State private var isLoading = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else if authService.isAuthenticated {
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
        .task {
            // 檢查登入狀態
            if authService.isAuthenticated {
                await authService.validateSession()
            }
            // 延遲一小段時間以展示載入動畫
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 秒
            withAnimation(.easeInOut(duration: 0.3)) {
                isLoading = false
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
