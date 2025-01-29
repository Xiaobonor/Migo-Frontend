import SwiftUI

struct DiaryCard: View {
    let entry: DiaryEntry
    let onTap: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(dateFormatter.string(from: entry.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let firstEmotion = entry.emotions.first,
                       let emoji = EmotionHelper.emojiFor(emotion: firstEmotion) {
                        Text(emoji)
                            .font(.title3)
                    }
                }
                
                // Title
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                // Content Preview
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Media Preview
                if !entry.medias.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.medias) { media in
                                AsyncImage(url: media.url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                
                // Tags
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

enum EmotionHelper {
    static func emojiFor(emotion: String) -> String? {
        let emotionToEmoji = [
            "happy": "😊",
            "sad": "😢",
            "angry": "😡",
            "tired": "😴",
            "thoughtful": "🤔",
            "peaceful": "😌",
            "excited": "🥳",
            "anxious": "😰",
            "loved": "🥰",
            "confident": "😎"
        ]
        return emotionToEmoji[emotion]
    }
} 