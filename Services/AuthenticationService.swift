import Foundation
import GoogleSignIn
import GoogleSignInSwift

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {
        // 檢查是否有已保存的登入狀態
        Task {
            await checkAuthStatus()
        }
    }
    
    // 檢查認證狀態
    @MainActor
    private func checkAuthStatus() async {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            isAuthenticated = false
            return
        }
        
        APIService.shared.setAccessToken(token)
        
        do {
            currentUser = try await APIService.shared.getCurrentUser()
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            self.error = (error as? APIError)?.message ?? error.localizedDescription
        }
    }
    
    // Google 登入
    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        error = nil
        
        guard let topVC = await UIApplication.shared.topViewController() else {
            isLoading = false
            error = "無法獲取視窗控制器"
            return
        }
        
        let config = GIDConfiguration(clientID: APIConfig.Google.clientId)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            // 獲取 ID Token
            guard let idToken = result.user.idToken?.tokenString else {
                throw APIError.authenticationError
            }
            
            // 使用 ID Token 獲取 access token
            let authResponse = try await APIService.shared.handleGoogleSignIn(idToken: idToken)
            
            // 保存 token
            UserDefaults.standard.set(authResponse.access_token, forKey: "accessToken")
            APIService.shared.setAccessToken(authResponse.access_token)
            
            // 獲取用戶資料
            currentUser = try await APIService.shared.getCurrentUser()
            isAuthenticated = true
            
        } catch {
            self.error = (error as? APIError)?.message ?? error.localizedDescription
            print("Google Sign-In Error: \(error)")
        }
        
        isLoading = false
    }
    
    // 登出
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.removeObject(forKey: "accessToken")
        APIService.shared.setAccessToken("")
        currentUser = nil
        isAuthenticated = false
    }
}

// MARK: - UIApplication Extension
extension UIApplication {
    func topViewController() async -> UIViewController? {
        guard let scene = await self.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return nil
        }
        return window.rootViewController?.topViewController()
    }
}

extension UIViewController {
    func topViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topViewController() ?? tab
        }
        return self
    }
} 