import Foundation

struct DiaryEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let date: Date
    var title: String
    var content: String
    var emotions: [String]
    var medias: [Media]
    var tags: [String]
    var writingTimeSeconds: Int
    var importedData: [String: String]?
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String,
         userId: String,
         date: Date,
         title: String,
         content: String,
         emotions: [String],
         medias: [Media],
         tags: [String],
         writingTimeSeconds: Int,
         importedData: [String: String]?,
         createdAt: Date,
         updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.date = date
        self.title = title
        self.content = content
        self.emotions = emotions
        self.medias = medias
        self.tags = tags
        self.writingTimeSeconds = writingTimeSeconds
        self.importedData = importedData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case date
        case title
        case content
        case emotions
        case medias
        case tags
        case writingTimeSeconds = "writing_time_seconds"
        case importedData = "imported_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        date = try container.decode(Date.self, forKey: .date)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        emotions = try container.decode([String].self, forKey: .emotions)
        medias = try container.decode([Media].self, forKey: .medias)
        tags = try container.decode([String].self, forKey: .tags)
        writingTimeSeconds = try container.decode(Int.self, forKey: .writingTimeSeconds)
        importedData = try container.decodeIfPresent([String: String].self, forKey: .importedData)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(date, forKey: .date)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(emotions, forKey: .emotions)
        try container.encode(medias, forKey: .medias)
        try container.encode(tags, forKey: .tags)
        try container.encode(writingTimeSeconds, forKey: .writingTimeSeconds)
        try container.encodeIfPresent(importedData, forKey: .importedData)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

struct Media: Codable, Identifiable {
    let id: String
    let type: MediaType
    let url: URL
    
    enum MediaType: String, Codable {
        case image
        case video
        case audio
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case url
    }
}

struct DiaryResponse: Codable {
    let id: String
    let userId: String
    let date: Date
    let entries: [DiaryEntry]
    let isPublic: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case date
        case entries
        case isPublic = "is_public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 