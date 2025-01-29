import Foundation

// MARK: - Empty Response
struct EmptyResponse: Codable {}

class DiaryService: ObservableObject {
    static let shared = DiaryService()
    private let apiService = APIService.shared
    
    @Published var diaries: [DiaryResponse] = []
    @Published var quickNotes: [QuickNote] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {}
    
    // MARK: - Diary CRUD
    
    func createOrUpdateDiary(_ entry: DiaryEntry) async throws -> DiaryResponse {
        isLoading = true
        defer { isLoading = false }
        
        let endpoint = APIEndpoint.diaries
        let body = try JSONEncoder().encode(entry)
        let response: DiaryResponse = try await apiService.makeRequest(
            endpoint,
            method: "POST",
            body: body
        )
        return response
    }
    
    func getDiaries(skip: Int = 0, limit: Int = 100, startDate: Date? = nil, endDate: Date? = nil) async throws -> [DiaryResponse] {
        isLoading = true
        defer { isLoading = false }
        
        var urlComponents = URLComponents(string: "\(APIConfig.baseURL)/diaries")
        urlComponents?.queryItems = [
            URLQueryItem(name: "skip", value: "\(skip)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let startDate = startDate {
            urlComponents?.queryItems?.append(
                URLQueryItem(name: "start_date", value: formatDate(startDate))
            )
        }
        
        if let endDate = endDate {
            urlComponents?.queryItems?.append(
                URLQueryItem(name: "end_date", value: formatDate(endDate))
            )
        }
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        let endpoint = APIEndpoint.diariesList
        let response: [DiaryResponse] = try await apiService.makeRequest(endpoint)
        return response
    }
    
    func getDiaryByDate(_ date: Date) async throws -> DiaryResponse {
        isLoading = true
        defer { isLoading = false }
        
        let formattedDate = formatDate(date)
        let endpoint = APIEndpoint.diaryByDate(formattedDate)
        let response: DiaryResponse = try await apiService.makeRequest(endpoint)
        return response
    }
    
    func getDiary(id: String) async throws -> DiaryResponse {
        isLoading = true
        defer { isLoading = false }
        
        let endpoint = APIEndpoint.diary(id)
        let response: DiaryResponse = try await apiService.makeRequest(endpoint)
        return response
    }
    
    func deleteDiary(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let endpoint = APIEndpoint.diary(id)
        let _: EmptyResponse = try await apiService.makeRequest(endpoint, method: "DELETE")
    }
    
    func deleteDiaryEntry(diaryId: String, entryId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let endpoint = APIEndpoint.diaryEntry(diaryId, entryId)
        let _: EmptyResponse = try await apiService.makeRequest(endpoint, method: "DELETE")
    }
    
    // MARK: - Quick Notes CRUD
    
    func createQuickNote(_ note: QuickNote) async throws -> QuickNote {
        isLoading = true
        defer { isLoading = false }
        
        let endpoint = APIEndpoint.notes
        let body = try JSONEncoder().encode(note)
        let response: QuickNote = try await apiService.makeRequest(
            endpoint,
            method: "POST",
            body: body
        )
        return response
    }
    
    func getQuickNotes(skip: Int = 0, limit: Int = 100) async throws -> [QuickNote] {
        isLoading = true
        defer { isLoading = false }
        
        var urlComponents = URLComponents(string: "\(APIConfig.baseURL)/notes")
        urlComponents?.queryItems = [
            URLQueryItem(name: "skip", value: "\(skip)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        let endpoint = APIEndpoint.notesList
        let response: [QuickNote] = try await apiService.makeRequest(endpoint)
        return response
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - API Endpoints
extension APIEndpoint {
    static var diaries: Self { .init(path: "/diaries") }
    static var diariesList: Self { .init(path: "/diaries") }
    static func diaryByDate(_ date: String) -> Self {
        .init(path: "/diaries/by-date/\(date)")
    }
    static func diary(_ id: String) -> Self {
        .init(path: "/diaries/\(id)")
    }
    static func diaryEntry(_ diaryId: String, _ entryId: String) -> Self {
        .init(path: "/diaries/\(diaryId)/entries/\(entryId)")
    }
    static var notes: Self { .init(path: "/notes") }
    static var notesList: Self { .init(path: "/notes") }
} 