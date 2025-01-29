import Foundation

struct QuickNote: Identifiable, Codable {
    let id: String
    let userId: String
    let content: String
    let type: NoteType
    let emotions: [String]
    let medias: [Media]
    let location: Location?
    let createdAt: Date
    var updatedAt: Date
    
    enum NoteType: String, Codable {
        case text
        case voice
        case drawing
    }
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
        let name: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId = "user_id"
        case content
        case type
        case emotions
        case medias
        case location
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 