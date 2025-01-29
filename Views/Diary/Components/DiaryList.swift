import SwiftUI

struct DiaryList: View {
    let entries: [DiaryEntry]
    let onEntryTap: (DiaryEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("diary.entries", comment: ""))
                .font(.headline)
            
            if entries.isEmpty {
                Text(NSLocalizedString("diary.entries.empty", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        DiaryCard(entry: entry, onTap: { onEntryTap(entry) })
                    }
                }
            }
        }
    }
} 