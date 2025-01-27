import Foundation

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://192.168.1.102:8000"
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
    static let googleSignIn = "/auth/google/signin"
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
    private let jsonDecoder: JSONDecoder
    
    private init() {
        jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
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
        
        // 打印回應數據，用於調試
        if let jsonString = String(data: data, encoding: .utf8) {
            print("API Response: \(jsonString)")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try jsonDecoder.decode(T.self, from: data)
            } catch {
                print("Decoding Error: \(error)")
                throw APIError.decodingError
            }
        case 401:
            throw APIError.authenticationError
        default:
            if let errorResponse = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
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
    
    // 處理 Google 登入
    func handleGoogleSignIn(idToken: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(["id_token": idToken])
        return try await request(APIEndpoint.googleSignIn, method: "POST", body: body)
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
    let id: String?
    let email: String
    let name: String
    let picture: String?
    let nickname: String?
    let bio: String?
    let birthday: Date?
    let gender: String?
    let phone: String?
    let followersCount: Int?
    let followingCount: Int?
    let language: String?
    let notificationEnabled: Bool?
    let theme: String?
    let createdAt: Date?
    let lastLogin: Date?
    let lastActive: Date?
    let country: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 必需欄位
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        
        // 可選欄位
        id = try container.decodeIfPresent(String.self, forKey: .id)
        picture = try container.decodeIfPresent(String.self, forKey: .picture)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        notificationEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationEnabled)
        theme = try container.decodeIfPresent(String.self, forKey: .theme)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        lastLogin = try container.decodeIfPresent(Date.self, forKey: .lastLogin)
        lastActive = try container.decodeIfPresent(Date.self, forKey: .lastActive)
        country = try container.decodeIfPresent(String.self, forKey: .country)
    }
} 
