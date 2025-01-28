import Foundation
import GoogleSignIn
import GoogleSignInSwift

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var shouldShowAuthAlert = false
    @Published var currentUser: User?
    
    private let defaults = UserDefaults.standard
    private let apiService = APIService.shared
    
    init() {
        // 配置 Google Sign In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: APIConfig.Google.clientId)
        
        // 檢查是否有已保存的登入狀態
        Task {
            await restoreUserSession()
        }
    }
    
    @MainActor
    private func restoreUserSession() async {
        // 檢查是否有已保存的登入狀態
        if defaults.isLoggedIn {
            isLoading = true
            defer { isLoading = false }
            
            print(NSLocalizedString("auth.message.restoring_session", comment: ""))
            
            do {
                // 嘗試恢復 Google Sign In 狀態
                let googleUser = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                
                // 驗證 ID Token
                guard let idToken = googleUser.idToken?.tokenString else {
                    throw AuthError.invalidToken
                }
                
                print(NSLocalizedString("auth.message.token_updated", comment: ""))
                
                // 更新 token
                defaults.authToken = idToken
                
                // 更新用戶資料
                let userData = """
                {
                    "_id": "\(googleUser.userID ?? "")",
                    "email": "\(googleUser.profile?.email ?? NSLocalizedString("profile.default.email", comment: ""))",
                    "name": "\(googleUser.profile?.name ?? NSLocalizedString("profile.default.name", comment: ""))",
                    "picture": "\(googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "")",
                    "nickname": "\(googleUser.profile?.givenName ?? "")"
                }
                """.data(using: .utf8)!
                
                let decoder = JSONDecoder()
                currentUser = try decoder.decode(User.self, from: userData)
                isAuthenticated = true
                
                print(NSLocalizedString("auth.message.session_restored", comment: ""))
                
            } catch {
                // 如果恢復過程出錯，清除本地存儲
                await forceLogout(reason: "auth.error.session_expired")
            }
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let topVC = await UIApplication.shared.topViewController() else {
            print(NSLocalizedString("debug.error.top_vc_missing", comment: ""))
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.internal", comment: "")
            }
            return
        }
        
        do {
            print(NSLocalizedString("auth.message.logging_in", comment: ""))
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            let googleUser = result.user
            
            // 驗證 ID Token
            guard let idToken = googleUser.idToken?.tokenString else {
                print(NSLocalizedString("debug.error.no_id_token", comment: ""))
                throw AuthError.invalidToken
            }
            
            print(NSLocalizedString("debug.success.id_token", comment: ""))
            
            // 從 Google 用戶資料創建用戶
            let userData = """
            {
                "_id": "\(googleUser.userID ?? "")",
                "email": "\(googleUser.profile?.email ?? NSLocalizedString("profile.default.email", comment: ""))",
                "name": "\(googleUser.profile?.name ?? NSLocalizedString("profile.default.name", comment: ""))",
                "picture": "\(googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "")",
                "nickname": "\(googleUser.profile?.givenName ?? "")"
            }
            """.data(using: .utf8)!
            
            print(NSLocalizedString("debug.success.user_data", comment: ""))
            
            let decoder = JSONDecoder()
            do {
                currentUser = try decoder.decode(User.self, from: userData)
                print(NSLocalizedString("debug.success.decode", comment: ""))
            } catch {
                print("\(NSLocalizedString("debug.error.decode", comment: "")): \(error)")
                throw AuthError.decodingError
            }
            
            // 存儲登入狀態和 token
            await MainActor.run {
                defaults.isLoggedIn = true
                defaults.authToken = idToken
                defaults.lastLoginDate = Date()
                self.isAuthenticated = true
                self.error = nil
            }
            
            print(NSLocalizedString("debug.success.signin", comment: ""))
            
        } catch let error as GIDSignInError {
            print("\(NSLocalizedString("debug.error.signin", comment: "")): \(error.localizedDescription)")
            print("Error code: \(error.code)")
            await MainActor.run {
                switch error.code {
                case .canceled:
                    self.error = NSLocalizedString("auth.error.canceled", comment: "")
                case .EMM:
                    self.error = NSLocalizedString("auth.error.enterprise", comment: "")
                case .hasNoAuthInKeychain:
                    self.error = NSLocalizedString("auth.error.no_saved_auth", comment: "")
                case .unknown:
                    self.error = NSLocalizedString("auth.error.unknown", comment: "")
                @unknown default:
                    self.error = NSLocalizedString("auth.error.google_signin", comment: "")
                }
            }
        } catch AuthError.invalidToken {
            print(NSLocalizedString("validation.token.invalid", comment: ""))
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.invalid_token", comment: "")
            }
        } catch AuthError.decodingError {
            print(NSLocalizedString("debug.error.decode", comment: ""))
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.decoding", comment: "")
            }
        } catch {
            print("\(NSLocalizedString("auth.error.unknown", comment: "")): \(error)")
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.unknown", comment: "")
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        defaults.clearAuthData()
        isAuthenticated = false
        currentUser = nil
        print(NSLocalizedString("auth.message.logged_out", comment: ""))
    }
    
    func validateSession() {
        Task {
            // 檢查 token 是否存在且有效
            guard let token = defaults.authToken else {
                await forceLogout(reason: "auth.error.token_missing")
                return
            }
            
            // 這裡可以添加與後端的 token 驗證
            // let isValid = await validateTokenWithBackend(token)
            let isValid = true // 臨時模擬 token 驗證
            
            if !isValid {
                await forceLogout(reason: "auth.error.token_expired")
            }
        }
    }
    
    @MainActor
    private func forceLogout(reason: String) {
        signOut()
        shouldShowAuthAlert = true
        error = NSLocalizedString(reason, comment: "Auth error")
    }
    
    @MainActor
    private func fetchUserProfile() async {
        do {
            // 嘗試獲取已登入的 Google 用戶
            if let currentUser = try? await GIDSignIn.sharedInstance.currentUser {
                let userData = """
                {
                    "_id": "\(currentUser.userID ?? "")",
                    "email": "\(currentUser.profile?.email ?? "")",
                    "name": "\(currentUser.profile?.name ?? "")",
                    "picture": "\(currentUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? "")",
                    "nickname": "\(currentUser.profile?.givenName ?? "")"
                }
                """.data(using: .utf8)!
                
                let decoder = JSONDecoder()
                self.currentUser = try decoder.decode(User.self, from: userData)
            } else {
                throw AuthError.invalidToken
            }
        } catch {
            self.error = NSLocalizedString("auth.error.profile_fetch", comment: "Failed to fetch user profile")
        }
    }
}

enum AuthError: Error {
    case invalidToken
    case networkError
    case decodingError
    case unknown
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
