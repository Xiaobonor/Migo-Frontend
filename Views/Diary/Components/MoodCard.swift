import SwiftUI

struct MoodCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("diary.mood", comment: "Today's mood section"))
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(["😊", "😐", "😢", "😡", "🤔"], id: \.self) { emoji in
                    Button(action: {}) {
                        Text(emoji)
                            .font(.system(size: 30))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
} 