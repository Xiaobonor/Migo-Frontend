import SwiftUI

struct QuickNotesList: View {
    let notes: [QuickNote]
    let onNoteTap: (QuickNote) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("diary.quick_notes", comment: ""))
                .font(.headline)
            
            if notes.isEmpty {
                Text(NSLocalizedString("diary.quick_notes.empty", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(notes) { note in
                        QuickNoteCard(note: note, onTap: { onNoteTap(note) })
                    }
                }
            }
        }
    }
} 