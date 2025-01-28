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
    case googleSignIn
    case me
    
    var path: String {
        switch self {
        case .googleSignIn:
            return "/auth/google/signin"
        case .me:
            return "/auth/me"
        }
    }
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case authenticationError
    case decodingError
    case serverError(String)
    case noToken
    
    var message: String {
        switch self {
        case .invalidURL:
            return "無效的 URL"
        case .networkError(let error):
            return "網路錯誤：\(error.localizedDescription)"
        case .invalidResponse:
            return "無效的伺服器響應"
        case .authenticationError:
            return "認證錯誤"
        case .decodingError:
            return "資料解析錯誤"
        case .serverError(let message):
            return message
        case .noToken:
            return "缺少有效的 token"
        }
    }
}

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private let jsonDecoder: JSONDecoder
    
    init() {
        jsonDecoder = JSONDecoder()
        
        // 自定義日期解析策略
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 嘗試不同的日期格式
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd"
            ]
            
            for format in formats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "無法解析日期：\(dateString)"
                )
            )
        }
        
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
    }
    
    // 通用請求方法
    private func request<T: Decodable>(_ endpoint: APIEndpoint, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint.path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加 Authorization Header
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // 打印響應數據（僅用於調試）
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response data: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try jsonDecoder.decode(T.self, from: data)
                    print("成功解碼響應數據：\(decodedResponse)")
                    return decodedResponse
                } catch {
                    print("解碼錯誤：\(error)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("找不到鍵：\(key)，上下文：\(context)")
                        case .valueNotFound(let type, let context):
                            print("找不到值，類型：\(type)，上下文：\(context)")
                        case .typeMismatch(let type, let context):
                            print("類型不匹配，預期類型：\(type)，上下文：\(context)")
                        case .dataCorrupted(let context):
                            print("數據損壞：\(context)")
                        @unknown default:
                            print("未知解碼錯誤：\(decodingError)")
                        }
                    }
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.authenticationError
            default:
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                throw APIError.serverError(errorResponse?.detail ?? "未知錯誤")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // 獲取當前用戶資料
    func getCurrentUser() async throws -> User {
        return try await request(.me)
    }
    
    // 處理 Google 登入
    func handleGoogleSignIn(idToken: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(["id_token": idToken])
        return try await request(.googleSignIn, method: "POST", body: body)
    }
}

// MARK: - Models
struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

struct ErrorResponse: Codable {
    let detail: String
} 
