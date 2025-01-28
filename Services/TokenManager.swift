import Foundation
import SwiftKeychainWrapper
import Security

class TokenManager {
    static let shared = TokenManager()
    private let keychain = KeychainWrapper.standard
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Token 存儲
    func saveTokens(_ response: TokenResponse) {
        // 保存 tokens
        _ = keychain.set(response.accessToken, forKey: TokenType.access.storageKey)
        _ = keychain.set(response.refreshToken, forKey: TokenType.refresh.storageKey)
        
        // 計算並保存過期時間
        let accessExpiration = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        let refreshExpiration = Date().addingTimeInterval(TimeInterval(response.expiresIn * 5)) // refresh token 有效期是 access token 的 5 倍
        
        defaults.set(accessExpiration.timeIntervalSince1970, forKey: TokenType.access.expirationKey)
        defaults.set(refreshExpiration.timeIntervalSince1970, forKey: TokenType.refresh.expirationKey)
    }
    
    // MARK: - Token 獲取
    func getToken(_ type: TokenType) -> String? {
        return keychain.string(forKey: type.storageKey)
    }
    
    // MARK: - Token 驗證
    func isTokenValid(_ type: TokenType) -> Bool {
        guard let expirationTime = defaults.object(forKey: type.expirationKey) as? TimeInterval else {
            return false
        }
        
        // 提前 30 秒判斷過期，以防止邊界情況
        let expirationDate = Date(timeIntervalSince1970: expirationTime)
        return Date().addingTimeInterval(30) < expirationDate
    }
    
    // MARK: - Token 刪除
    func clearTokens() {
        // 從 Keychain 刪除 tokens
        _ = keychain.removeObject(forKey: TokenType.access.storageKey)
        _ = keychain.removeObject(forKey: TokenType.refresh.storageKey)
        
        // 從 UserDefaults 刪除過期時間
        defaults.removeObject(forKey: TokenType.access.expirationKey)
        defaults.removeObject(forKey: TokenType.refresh.expirationKey)
    }
    
    // MARK: - Token 狀態檢查
    func checkTokenStatus() -> TokenStatus {
        if isTokenValid(.access) {
            return .valid
        } else if isTokenValid(.refresh) {
            return .needsRefresh
        } else {
            return .needsReauth
        }
    }
}

// MARK: - Token 狀態枚舉
enum TokenStatus {
    case valid           // Token 有效
    case needsRefresh    // 需要刷新
    case needsReauth     // 需要重新認證
} 