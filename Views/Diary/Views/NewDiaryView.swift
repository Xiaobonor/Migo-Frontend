import SwiftUI
import PhotosUI

struct NewDiaryView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var diaryService = DiaryService.shared
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var selectedTags: Set<String> = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var showError = false
    @State private var startTime: Date?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Field
                    TextField(NSLocalizedString("diary.title_placeholder", comment: ""), text: $title)
                        .font(.title2)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // Content Editor
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text(NSLocalizedString("diary.content_placeholder", comment: ""))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Mood Selector
                    MoodSelector(selectedEmotions: $selectedEmotions)
                        .padding(.horizontal)
                    
                    // Media Picker
                    MediaPicker(selectedItems: $selectedItems,
                              selectedImages: $selectedImages)
                        .padding(.horizontal)
                    
                    // Tag Selector
                    TagSelector(selectedTags: $selectedTags)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(NSLocalizedString("diary.new", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        Task {
                            await saveDiary()
                        }
                    }
                    .disabled(content.isEmpty || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .alert(NSLocalizedString("error.title", comment: ""), isPresented: $showError) {
            Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {}
        } message: {
            Text(error ?? NSLocalizedString("error.unknown", comment: ""))
        }
        .onAppear {
            startTime = Date()
        }
    }
    
    // MARK: - Methods
    private func saveDiary() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let writingTimeSeconds = Int(Date().timeIntervalSince(startTime ?? Date()))
            
            let entryData: [String: Any] = [
                "_id": UUID().uuidString,
                "user_id": "current_user_id", // TODO: Get from auth service
                "date": Date(),
                "title": title,
                "content": content,
                "emotions": Array(selectedEmotions),
                "medias": [], // TODO: Upload images and get URLs
                "tags": Array(selectedTags),
                "writing_time_seconds": writingTimeSeconds,
                "imported_data": nil as [String: String]?,
                "created_at": Date(),
                "updated_at": Date()
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: entryData)
            let entry = try JSONDecoder().decode(DiaryEntry.self, from: jsonData)
            
            _ = try await diaryService.createOrUpdateDiary(entry)
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            self.error = error.localizedDescription
            showError = true
        }
    }
} 