import Foundation

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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 必需欄位
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        followersCount = try container.decode(Int.self, forKey: .followersCount)
        followingCount = try container.decode(Int.self, forKey: .followingCount)
        language = try container.decode(String.self, forKey: .language)
        notificationEnabled = try container.decode(Bool.self, forKey: .notificationEnabled)
        theme = try container.decode(String.self, forKey: .theme)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        // 可選欄位
        picture = try? container.decode(URL.self, forKey: .picture)
        nickname = try? container.decode(String.self, forKey: .nickname)
        bio = try? container.decode(String.self, forKey: .bio)
        birthday = try? container.decode(Date.self, forKey: .birthday)
        gender = try? container.decode(String.self, forKey: .gender)
        phone = try? container.decode(String.self, forKey: .phone)
        lastLogin = try? container.decode(Date.self, forKey: .lastLogin)
        lastActive = try? container.decode(Date.self, forKey: .lastActive)
        country = try? container.decode(String.self, forKey: .country)
    }
} 