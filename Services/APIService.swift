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
    case refresh
    
    var path: String {
        switch self {
        case .googleSignIn:
            return "/auth/google/signin"
        case .me:
            return "/auth/me"
        case .refresh:
            return "/auth/refresh"
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
    private let tokenManager = TokenManager.shared
    private let retryLimit = 3
    
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
    
    // MARK: - 請求方法
    private func request<T: Decodable>(_ endpoint: APIEndpoint, method: String = "GET", body: Data? = nil, retryCount: Int = 0) async throws -> T {
        // 檢查 token 狀態
        if endpoint != .googleSignIn && endpoint != .refresh {
            switch tokenManager.checkTokenStatus() {
            case .needsRefresh:
                // 嘗試刷新 token
                _ = try await refreshToken()
            case .needsReauth:
                throw APIError.authenticationError
            default:
                break
            }
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint.path)") else {
            throw APIError.invalidURL
        }
        
        // 創建 URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 根據不同端點添加不同的 token
        if endpoint == .refresh {
            if let refreshToken = tokenManager.getToken(.refresh) {
                urlRequest.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
            }
        } else if endpoint != .googleSignIn {
            if let accessToken = tokenManager.getToken(.access) {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        let session = URLSession.shared
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
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
                if retryCount < retryLimit && endpoint != .refresh {
                    // 嘗試刷新 token 並重試請求
                    _ = try await refreshToken()
                    return try await request(endpoint, method: method, body: body, retryCount: retryCount + 1)
                }
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
    
    // MARK: - Token 刷新
    func refreshToken() async throws -> TokenResponse {
        print("開始刷新 token...")
        do {
            let response: TokenResponse = try await request(.refresh, method: "POST")
            tokenManager.saveTokens(response)
            print("Token 刷新成功")
            return response
        } catch {
            print("Token 刷新失敗：\(error)")
            throw APIError.authenticationError
        }
    }
    
    // MARK: - API 方法
    func handleGoogleSignIn(idToken: String) async throws -> TokenResponse {
        let body = try JSONEncoder().encode(["id_token": idToken])
        let response: TokenResponse = try await request(.googleSignIn, method: "POST", body: body)
        tokenManager.saveTokens(response)
        return response
    }
    
    func getCurrentUser() async throws -> User {
        return try await request(.me)
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
