import Foundation

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://localhost:8000"
    static let version = "1.0.0"
    
    // Google OAuth 配置
    struct Google {
        // Bundle ID
        static let bundleId = "tw.xiaobo.Migo-Frontend"
        
        // 從 Google Cloud Console 獲取的 Client ID
        static let clientId = "893906920868-bqg5bdlfvrrlstl1a2mt7t3hp5om9gen.apps.googleusercontent.com"
        
        // 用於 URL Scheme 的反向 Client ID
        static let reversedClientId = "com.googleusercontent.apps.893906920868-bqg5bdlfvrrlstl1a2mt7t3hp5om9gen"
    }
}

// MARK: - API Endpoints
enum APIEndpoint {
    static let googleLogin = "/auth/google/login"
    static let googleCallback = "/auth/google/callback"
    static let me = "/auth/me"
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case authenticationError
    case decodingError
    case serverError(String)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .networkError(let error):
            return "網路錯誤: \(error.localizedDescription)"
        case .invalidResponse:
            return "無效的伺服器回應"
        case .authenticationError:
            return "認證失敗"
        case .decodingError:
            return "資料解析錯誤"
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private var accessToken: String?
    
    private init() {}
    
    // 設置 access token
    func setAccessToken(_ token: String) {
        accessToken = token
    }
    
    // 獲取 access token
    func getAccessToken() -> String? {
        return accessToken
    }
    
    // 建立帶有認證的請求標頭
    private func authorizedHeaders() -> [String: String] {
        var headers = ["Content-Type": "application/json"]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    // 處理 API 回應
    private func handleResponse<T: Codable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        case 401:
            throw APIError.authenticationError
        default:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.detail)
            }
            throw APIError.invalidResponse
        }
    }
    
    // 發送請求
    private func request<T: Codable>(_ endpoint: String,
                                   method: String = "GET",
                                   body: Data? = nil) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = authorizedHeaders()
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            return try handleResponse(data, response)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // 獲取當前用戶資料
    func getCurrentUser() async throws -> User {
        return try await request(APIEndpoint.me)
    }
    
    // 處理 Google 登入回調
    func handleGoogleCallback(code: String) async throws -> AuthResponse {
        let endpoint = APIEndpoint.googleCallback + "?code=\(code)"
        return try await request(endpoint)
    }
}

// MARK: - Models
struct ErrorResponse: Codable {
    let detail: String
}

struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
}

struct User: Codable {
    let email: String
    let name: String
    let picture: URL?
    let nickname: String?
    let bio: String?
    let birthday: Date?
    let gender: String?
    let phone: String?
    let followersCount: Int
    let followingCount: Int
    let language: String
    let notificationEnabled: Bool
    let theme: String
    let createdAt: Date
    let lastLogin: Date?
    let lastActive: Date?
    let country: String?
    
    enum CodingKeys: String, CodingKey {
        case email, name, picture, nickname, bio, birthday, gender, phone
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case language
        case notificationEnabled = "notification_enabled"
        case theme
        case createdAt = "created_at"
        case lastLogin = "last_login"
        case lastActive = "last_active"
        case country
    }
} 