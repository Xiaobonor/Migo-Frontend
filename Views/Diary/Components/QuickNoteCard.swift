import SwiftUI

struct QuickNoteCard: View {
    let note: QuickNote
    let onTap: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Text(dateFormatter.string(from: note.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = note.location?.name {
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .imageScale(.small)
                            Text(location)
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
                
                // Content
                Group {
                    switch note.type {
                    case .text:
                        Text(note.content)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(3)
                        
                    case .voice:
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.blue)
                            Text(NSLocalizedString("diary.note.voice", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        
                    case .drawing:
                        if let firstMedia = note.medias.first {
                            AsyncImage(url: firstMedia.url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                                    .frame(height: 100)
                            }
                        }
                    }
                }
                
                // Media Preview
                if !note.medias.isEmpty && note.type != .drawing {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(note.medias) { media in
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
                
                // Emotions
                if !note.emotions.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(note.emotions, id: \.self) { emotion in
                            if let emoji = EmotionHelper.emojiFor(emotion: emotion) {
                                Text(emoji)
                                    .font(.caption)
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