import SwiftUI

struct TagSelector: View {
    @Binding var selectedTags: Set<String>
    @State private var newTag = ""
    @State private var isAddingTag = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 標題和新增按鈕
            HStack {
                Text("標籤")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isAddingTag.toggle() }) {
                    Image(systemName: isAddingTag ? "checkmark.circle.fill" : "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // 新增標籤輸入區
            if isAddingTag {
                HStack {
                    TextField("輸入標籤", text: $newTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !newTag.isEmpty {
                        Button("新增") {
                            addTag()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            // 已選擇的標籤
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    let tags = Array(selectedTags).sorted()
                    Group {
                        if tags.isEmpty {
                            Text("尚未新增標籤")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        } else {
                            Group {
                                if tags.count > 0 { tagView(tags[0]) }
                                if tags.count > 1 { tagView(tags[1]) }
                                if tags.count > 2 { tagView(tags[2]) }
                                if tags.count > 3 { tagView(tags[3]) }
                                if tags.count > 4 { tagView(tags[4]) }
                                if tags.count > 5 { tagView(tags[5]) }
                                if tags.count > 6 { tagView(tags[6]) }
                                if tags.count > 7 { tagView(tags[7]) }
                                if tags.count > 8 { tagView(tags[8]) }
                                if tags.count > 9 {
                                    Text("+\(tags.count - 9)")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func tagView(_ tag: String) -> some View {
        Button(action: { selectedTags.remove(tag) }) {
            HStack(spacing: 4) {
                Text("#\(tag)")
                    .font(.subheadline)
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tag.isEmpty {
            selectedTags.insert(tag)
            newTag = ""
            isAddingTag = false
        }
    }
} 
