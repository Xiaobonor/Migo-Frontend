import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

// Token 類型枚舉
enum TokenType: String {
    case access = "access"
    case refresh = "refresh"
    
    var storageKey: String {
        switch self {
        case .access:
            return "accessToken"
        case .refresh:
            return "refreshToken"
        }
    }
    
    var expirationKey: String {
        switch self {
        case .access:
            return "accessTokenExpiration"
        case .refresh:
            return "refreshTokenExpiration"
        }
    }
} 