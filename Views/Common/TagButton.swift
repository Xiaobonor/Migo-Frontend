import SwiftUI

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    init(tag: String, isSelected: Bool, action: @escaping () -> Void) {
        self.tag = tag
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text("#\(tag)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .blue : .gray)
                .cornerRadius(8)
        }
    }
} 