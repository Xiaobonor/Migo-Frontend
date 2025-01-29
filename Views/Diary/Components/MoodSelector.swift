import SwiftUI

struct MoodSelector: View {
    @Binding var selectedEmotions: Set<String>
    let availableEmotions = [
        "😊": "happy",
        "😢": "sad",
        "😡": "angry",
        "😴": "tired",
        "🤔": "thoughtful",
        "😌": "peaceful",
        "🥳": "excited",
        "😰": "anxious",
        "🥰": "loved",
        "😎": "confident"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("diary.mood.title", comment: ""))
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 44, maximum: 44), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(availableEmotions.keys.sorted()), id: \.self) { emoji in
                    let emotion = availableEmotions[emoji] ?? ""
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedEmotions.contains(emotion) {
                                selectedEmotions.remove(emotion)
                            } else {
                                selectedEmotions.insert(emotion)
                            }
                        }
                    }) {
                        Text(emoji)
                            .font(.system(size: 24))
                    }
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(selectedEmotions.contains(emotion) ?
                                  Color.blue.opacity(0.2) : Color.clear)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(selectedEmotions.contains(emotion) ?
                                        Color.blue : Color.gray.opacity(0.3),
                                        lineWidth: 1.5)
                    )
                    .scaleEffect(selectedEmotions.contains(emotion) ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7),
                             value: selectedEmotions.contains(emotion))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
} 