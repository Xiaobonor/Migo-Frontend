import SwiftUI

struct LegalDocumentView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    let documentType: DocumentType
    @State private var selectedSection: String?
    @State private var scrollOffset: CGFloat = 0
    @State private var showContent = false
    
    enum DocumentType {
        case privacyPolicy
        case terms
        
        var title: String {
            switch self {
            case .privacyPolicy:
                return NSLocalizedString("settings.privacy_policy.title", comment: "")
            case .terms:
                return NSLocalizedString("settings.terms.title", comment: "")
            }
        }
        
        var lastUpdated: String {
            switch self {
            case .privacyPolicy:
                return NSLocalizedString("settings.privacy_policy.last_updated", comment: "")
            case .terms:
                return NSLocalizedString("settings.terms.last_updated", comment: "")
            }
        }
        
        var content: String {
            switch self {
            case .privacyPolicy:
                return NSLocalizedString("settings.privacy_policy.content", comment: "")
            case .terms:
                return NSLocalizedString("settings.terms.content", comment: "")
            }
        }
        
        var sections: [(title: String, id: String)] {
            switch self {
            case .privacyPolicy:
                return [
                    (NSLocalizedString("settings.privacy_policy.section.data_collection", comment: ""), "data_collection"),
                    (NSLocalizedString("settings.privacy_policy.section.data_usage", comment: ""), "data_usage"),
                    (NSLocalizedString("settings.privacy_policy.section.data_protection", comment: ""), "data_protection"),
                    (NSLocalizedString("settings.privacy_policy.section.your_rights", comment: ""), "your_rights"),
                    (NSLocalizedString("settings.privacy_policy.section.cookies", comment: ""), "cookies")
                ]
            case .terms:
                return [
                    (NSLocalizedString("settings.terms.section.usage", comment: ""), "usage"),
                    (NSLocalizedString("settings.terms.section.account", comment: ""), "account"),
                    (NSLocalizedString("settings.terms.section.ip", comment: ""), "ip"),
                    (NSLocalizedString("settings.terms.section.changes", comment: ""), "changes"),
                    (NSLocalizedString("settings.terms.section.disclaimer", comment: ""), "disclaimer")
                ]
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -20)
                    
                    // Content
                    contentView
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .padding()
            }
            .coordinateSpace(name: "scroll")
            .overlay(
                // Navigation Bar Background
                GeometryReader { geometry in
                    Color(.systemBackground)
                        .opacity(scrollOffset > 0 ? 1 : 0)
                        .frame(height: geometry.safeAreaInsets.top + 44)
                        .blur(radius: 10)
                        .ignoresSafeArea()
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("common.done", comment: "Done button")) {
                    dismiss()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(documentType.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(documentType.lastUpdated)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Section Navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(documentType.sections, id: \.id) { section in
                        Button(action: {
                            withAnimation {
                                selectedSection = section.id
                            }
                        }) {
                            Text(section.title)
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedSection == section.id ?
                                              Color.blue : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedSection == section.id ?
                                               .white : .primary)
                        }
                    }
                }
            }
        }
        .padding(.top)
        .background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scroll")).minY
                )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        Text(documentType.content)
            .font(.body)
            .lineSpacing(4)
            .padding(.bottom, 40)
    }
}

// MARK: - Scroll Offset Preference Key
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview Provider
#Preview {
    NavigationView {
        LegalDocumentView(documentType: .privacyPolicy)
    }
} 