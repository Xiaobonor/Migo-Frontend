import SwiftUI

// MARK: - Custom Transitions
extension AnyTransition {
    static var smoothTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 1.02)).combined(with: .opacity),
            removal: .opacity.combined(with: .scale(scale: 0.98)).combined(with: .opacity)
        )
    }
}

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
    @Namespace private var animation
    @State private var animationState = AnimationState.initial
    @State private var isLoggingOut = false
    @State private var isPerformingSignOut = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
            } else {
                if authService.isAuthenticated {
                    mainView
                        .scaleEffect(isLoggingOut ? 0.98 : 1)
                        .opacity(isLoggingOut ? 0 : 1)
                        .blur(radius: isLoggingOut ? 10 : 0)
                        .transition(.smoothTransition)
                        .matchedGeometryEffect(id: "mainContainer", in: animation)
                } else {
                    WelcomeView()
                        .scaleEffect(animationState == .unauthenticated ? 1 : 0.98)
                        .opacity(animationState == .unauthenticated ? 1 : 0)
                        .blur(radius: animationState == .unauthenticated ? 0 : 10)
                        .transition(.smoothTransition)
                        .matchedGeometryEffect(id: "mainContainer", in: animation)
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.6), value: isLoggingOut)
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
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                        animationState = authService.isAuthenticated ? .authenticated : .unauthenticated
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
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            withAnimation(.easeInOut(duration: 0.8)) {
                animationState = isAuthenticated ? .authenticated : .unauthenticated
            }
        }
        .onAppear {
            authService.onSignInSuccess = {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animationState = .authenticated
                    isLoggingOut = false
                }
            }
            
            // 設置登出前的動畫回調
            authService.onSignOutStart = {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoggingOut = true
                }
                // 延遲執行登出操作，給動畫足夠的時間
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPerformingSignOut = true
                    }
                }
            }
            
            // 設置實際登出完成的回調
            authService.onSignOutSuccess = {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animationState = .unauthenticated
                    isLoggingOut = false
                }
            }
        }
        .onChange(of: isPerformingSignOut) { isPerforming in
            if isPerforming {
                // 延遲執行實際的登出操作
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    authService.performSignOut()
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

// MARK: - Animation State
enum AnimationState {
    case initial
    case loading
    case authenticated
    case unauthenticated
}

// MARK: - Preview Provider
#Preview {
    ContentView()
} 
