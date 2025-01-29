import SwiftUI

struct DiaryDetailView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var diaryService = DiaryService.shared
    let entry: DiaryEntry
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedEmotions: Set<String>
    @State private var editedTags: Set<String>
    @State private var showingDeleteAlert = false
    @State private var isLoading = false
    @State private var error: String?
    @State private var showError = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Initialization
    init(entry: DiaryEntry) {
        self.entry = entry
        _editedTitle = State(initialValue: entry.title)
        _editedContent = State(initialValue: entry.content)
        _editedEmotions = State(initialValue: Set(entry.emotions))
        _editedTags = State(initialValue: Set(entry.tags))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(dateFormatter.string(from: entry.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Writing Time
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("\(entry.writingTimeSeconds / 60) min")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    if isEditing {
                        TextField(NSLocalizedString("diary.title_placeholder", comment: ""),
                                text: $editedTitle)
                            .font(.title)
                            .textFieldStyle(.roundedBorder)
                    } else if !entry.title.isEmpty {
                        Text(entry.title)
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                
                // Content
                Group {
                    if isEditing {
                        TextEditor(text: $editedContent)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    } else {
                        Text(entry.content)
                            .font(.body)
                    }
                }
                
                // Media Gallery
                if !entry.medias.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(entry.medias) { media in
                                AsyncImage(url: media.url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Emotions
                if isEditing {
                    MoodSelector(selectedEmotions: $editedEmotions)
                } else if !entry.emotions.isEmpty {
                    HStack {
                        ForEach(entry.emotions, id: \.self) { emotion in
                            if let emoji = EmotionHelper.emojiFor(emotion: emotion) {
                                Text(emoji)
                                    .font(.title2)
                            }
                        }
                    }
                }
                
                // Tags
                if isEditing {
                    TagSelector(selectedTags: $editedTags)
                } else if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if isEditing {
                        Button(action: saveChanges) {
                            Label(NSLocalizedString("common.save", comment: ""),
                                  systemImage: "checkmark")
                        }
                        
                        Button(action: { isEditing = false }) {
                            Label(NSLocalizedString("common.cancel", comment: ""),
                                  systemImage: "xmark")
                        }
                    } else {
                        Button(action: { isEditing = true }) {
                            Label(NSLocalizedString("common.edit", comment: ""),
                                  systemImage: "pencil")
                        }
                        
                        Button(role: .destructive,
                               action: { showingDeleteAlert = true }) {
                            Label(NSLocalizedString("common.delete", comment: ""),
                                  systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(NSLocalizedString("diary.delete.title", comment: ""),
               isPresented: $showingDeleteAlert) {
            Button(NSLocalizedString("common.delete", comment: ""),
                   role: .destructive,
                   action: deleteDiary)
            Button(NSLocalizedString("common.cancel", comment: ""),
                   role: .cancel) {}
        } message: {
            Text(NSLocalizedString("diary.delete.message", comment: ""))
        }
        .alert(NSLocalizedString("error.title", comment: ""),
               isPresented: $showError) {
            Button(NSLocalizedString("common.ok", comment: ""),
                   role: .cancel) {}
        } message: {
            Text(error ?? NSLocalizedString("error.unknown", comment: ""))
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
    
    // MARK: - Methods
    private func saveChanges() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let updatedEntry = DiaryEntry(
                    id: entry.id,
                    userId: entry.userId,
                    date: entry.date,
                    title: editedTitle,
                    content: editedContent,
                    emotions: Array(editedEmotions),
                    medias: entry.medias,
                    tags: Array(editedTags),
                    writingTimeSeconds: entry.writingTimeSeconds,
                    importedData: entry.importedData,
                    createdAt: entry.createdAt,
                    updatedAt: Date()
                )
                
                _ = try await diaryService.createOrUpdateDiary(updatedEntry)
                
                await MainActor.run {
                    isEditing = false
                }
            } catch {
                self.error = error.localizedDescription
                showError = true
            }
        }
    }
    
    private func deleteDiary() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await diaryService.deleteDiary(id: entry.id)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                self.error = error.localizedDescription
                showError = true
            }
        }
    }
} 