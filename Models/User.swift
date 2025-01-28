import Foundation

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
    
    public init(from decoder: Decoder) throws {
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