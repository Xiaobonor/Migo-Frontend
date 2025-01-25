import SwiftUI

// MARK: - Colors
struct AppColors {
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")
    static let accent = Color("Accent")
    static let background = Color("Background")
    static let text = Color("Text")
    static let textSecondary = Color("TextSecondary")
}

// MARK: - Dimensions
struct AppDimensions {
    static let cornerRadius: CGFloat = 15
    static let padding: CGFloat = 16
    static let iconSize: CGFloat = 24
    static let cardShadowRadius: CGFloat = 2
}

// MARK: - Font Styles
extension Font {
    static func appTitle() -> Font {
        .system(.title, design: .rounded, weight: .bold)
    }
    
    static func appHeadline() -> Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }
    
    static func appBody() -> Font {
        .system(.body, design: .rounded)
    }
    
    static func appCaption() -> Font {
        .system(.caption, design: .rounded)
    }
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppDimensions.cornerRadius)
            .shadow(radius: AppDimensions.cardShadowRadius)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(AppColors.primary)
            .cornerRadius(AppDimensions.cornerRadius)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
}

// MARK: - Preview Helper
struct ThemePreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("App Title")
                    .font(.appTitle())
                
                Text("Headline")
                    .font(.appHeadline())
                
                Text("Body Text")
                    .font(.appBody())
                
                Text("Caption")
                    .font(.appCaption())
                
                VStack {
                    Text("Card Style Example")
                        .padding()
                }
                .cardStyle()
                
                Button("Primary Button") {}
                    .primaryButtonStyle()
            }
            .padding()
        }
    }
}

#Preview {
    ThemePreview()
} 