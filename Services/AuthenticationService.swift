import Foundation
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var shouldShowAuthAlert = false
    @Published var currentUser: User?
    
    private let defaults = UserDefaults.standard
    private let apiService = APIService.shared
    private let tokenManager = TokenManager.shared
    
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
        print("開始恢復用戶會話...")
        
        // 檢查 token 狀態
        switch tokenManager.checkTokenStatus() {
        case .valid:
            print("Token 有效，正在恢復會話...")
            do {
                let userData = try await apiService.getCurrentUser()
                self.currentUser = userData
                self.isAuthenticated = true
                print("會話恢復成功")
            } catch {
                print("恢復會話失敗：\(error)")
                // 直接清除資料並設為未登入
                silentLogout()
            }
            
        case .needsRefresh:
            print("Token 需要刷新，正在嘗試刷新...")
            do {
                let userData = try await apiService.getCurrentUser()
                self.currentUser = userData
                self.isAuthenticated = true
                print("Token 刷新成功")
            } catch {
                print("Token 刷新失敗：\(error)")
                // 直接清除資料並設為未登入
                silentLogout()
            }
            
        case .needsReauth:
            print("需要重新認證")
            // 直接清除資料並設為未登入
            silentLogout()
        }
    }
    
    func signInWithGoogle() async {
        print("開始 Google 登入流程...")
        isLoading = true
        defer { 
            isLoading = false
            print("Google 登入流程結束")
        }
        
        guard let topVC = await UIApplication.shared.topViewController() else {
            print("錯誤：無法獲取頂層視圖控制器")
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.internal", comment: "")
            }
            return
        }
        
        do {
            print("正在初始化 Google 登入...")
            
            // 1. Google 登入
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            let googleUser = result.user
            print("Google 登入成功")
            print("用戶 ID: \(googleUser.userID ?? "未知")")
            print("用戶郵箱: \(googleUser.profile?.email ?? "未知")")
            
            // 2. 獲取 ID Token
            guard let idToken = googleUser.idToken?.tokenString else {
                print("錯誤：無法獲取 ID Token")
                throw AuthError.noIDToken
            }
            print("成功獲取 ID Token")
            
            // 3. 與後端進行驗證
            print("正在與後端進行驗證...")
            let tokenResponse = try await apiService.handleGoogleSignIn(idToken: idToken)
            print("後端驗證成功")
            
            // 4. 使用 access token 獲取用戶資料
            print("正在獲取用戶詳細資料...")
            let userData = try await apiService.getCurrentUser()
            print("成功獲取用戶詳細資料")
            
            // 5. 更新本地狀態
            await MainActor.run {
                print("正在更新本地狀態...")
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.currentUser = userData
                    self.isAuthenticated = true
                }
                defaults.isLoggedIn = true
                defaults.lastLoginDate = Date()
                self.error = nil
                print("登入流程完成")
            }
            
        } catch let error as GIDSignInError {
            print("Google 登入錯誤：\(error.localizedDescription)")
            print("錯誤代碼：\(error.code.rawValue)")
            print("錯誤詳情：\(error)")
            await MainActor.run {
                switch error.code {
                case .canceled:
                    print("用戶取消登入")
                    self.error = NSLocalizedString("auth.error.canceled", comment: "")
                case .EMM:
                    print("企業管理錯誤")
                    self.error = NSLocalizedString("auth.error.enterprise", comment: "")
                case .hasNoAuthInKeychain:
                    print("Keychain 中無認證信息")
                    self.error = NSLocalizedString("auth.error.no_saved_auth", comment: "")
                case .unknown:
                    print("未知 Google 登入錯誤")
                    self.error = NSLocalizedString("auth.error.unknown", comment: "")
                @unknown default:
                    print("其他 Google 登入錯誤")
                    self.error = NSLocalizedString("auth.error.google_signin", comment: "")
                }
            }
        } catch APIError.authenticationError {
            print("後端認證錯誤")
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.invalid_token", comment: "")
            }
        } catch APIError.networkError(let error) {
            print("網路錯誤：\(error.localizedDescription)")
            print("錯誤詳情：\(error)")
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.network", comment: "")
            }
        } catch APIError.serverError(let message) {
            print("伺服器錯誤：\(message)")
            await MainActor.run {
                self.error = message
            }
        } catch {
            print("未預期的錯誤：\(error)")
            print("錯誤類型：\(type(of: error))")
            if let nsError = error as NSError? {
                print("Domain: \(nsError.domain)")
                print("Code: \(nsError.code)")
                print("Description: \(nsError.localizedDescription)")
                print("User Info: \(nsError.userInfo)")
            }
            await MainActor.run {
                self.error = NSLocalizedString("auth.error.unknown", comment: "")
            }
        }
    }
    
    func signOut() {
        print("開始登出流程...")
        GIDSignIn.sharedInstance.signOut()
        tokenManager.clearTokens()
        defaults.clearAuthData()
        isAuthenticated = false
        currentUser = nil
        print("登出完成")
    }
    
    func validateSession() async throws {
        print("開始驗證會話...")
        
        // 檢查 token 狀態
        switch tokenManager.checkTokenStatus() {
        case .valid:
            print("Token 有效，正在驗證...")
            try await apiService.getCurrentUser()
            print("Token 驗證成功")
            
        case .needsRefresh:
            print("Token 需要刷新，正在嘗試刷新...")
            do {
                _ = try await apiService.refreshToken()
                try await apiService.getCurrentUser()
                print("Token 刷新並驗證成功")
            } catch {
                print("Token 刷新失敗：\(error)")
                await MainActor.run {
                    silentLogout()
                }
                throw APIError.authenticationError
            }
            
        case .needsReauth:
            print("Token 需要重新認證")
            await MainActor.run {
                silentLogout()
            }
            throw APIError.authenticationError
        }
    }
    
    @MainActor
    private func silentLogout() {
        print("靜默登出...")
        GIDSignIn.sharedInstance.signOut()
        tokenManager.clearTokens()
        defaults.clearAuthData()
        isAuthenticated = false
        currentUser = nil
        error = nil
        shouldShowAuthAlert = false
        print("靜默登出完成")
    }
    
    @MainActor
    private func forceLogout(reason: String) {
        signOut()
        shouldShowAuthAlert = true
        error = NSLocalizedString(reason, comment: "Auth error")
    }
}

enum AuthError: Error {
    case invalidToken
    case networkError
    case decodingError
    case unknown
    case noIDToken
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
