import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // MARK: - Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language = "zh-Hant"
    @StateObject private var authService = AuthenticationService.shared
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage: String?
    
    // 動畫相關狀態
    @State private var loginTransition = false
    @Namespace private var animation
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else {
                ZStack {
                    if !authService.isAuthenticated {
                        WelcomeView()
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 1.1)),
                                    removal: .opacity.combined(with: .scale(scale: 0.9))
                                )
                            )
                    }
                    
                    if authService.isAuthenticated {
                        mainView
                            .transition(
                                .asymmetric(
                                    insertion: .modifier(
                                        active: TransitionModifier(scale: 1.1, opacity: 0, blur: 10),
                                        identity: TransitionModifier(scale: 1, opacity: 1, blur: 0)
                                    ),
                                    removal: .opacity
                                )
                            )
                            .matchedGeometryEffect(id: "mainView", in: animation)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: authService.isAuthenticated)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environment(\.locale, Locale(identifier: language))
        .alert(NSLocalizedString("auth.alert.session_expired.title", comment: "Session expired title"),
               isPresented: $authService.shouldShowAuthAlert) {
            Button(NSLocalizedString("common.ok", comment: "OK button"), role: .cancel) {
                authService.shouldShowAuthAlert = false
            }
        } message: {
            Text(authService.error ?? NSLocalizedString("auth.alert.session_expired.message", comment: "Session expired message"))
        }
        .alert(NSLocalizedString("error.title", comment: "Error"), isPresented: $hasError) {
            Button(NSLocalizedString("common.ok", comment: "OK button"), role: .cancel) {
                hasError = false
            }
        } message: {
            Text(errorMessage ?? NSLocalizedString("error.unknown", comment: "Unknown error"))
        }
        .task {
            do {
                // 檢查登入狀態
                if authService.isAuthenticated {
                    try await authService.validateSession()
                }
                
                // 延遲一小段時間以展示載入動畫
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 秒
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoading = false
                    }
                }
            } catch {
                print("ContentView task error: \(error)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    hasError = true
                    isLoading = false
                }
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

// MARK: - Transition Modifier
struct TransitionModifier: ViewModifier {
    let scale: CGFloat
    let opacity: CGFloat
    let blur: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: blur)
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
} 
