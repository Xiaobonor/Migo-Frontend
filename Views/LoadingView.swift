import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.97, green: 0.97, blue: 0.99)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo
                Image(systemName: "hourglass.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .opacity(showLogo ? 1 : 0)
                    .scaleEffect(showLogo ? 1 : 0.5)
                
                // 載入文字
                Text(NSLocalizedString("loading.message", comment: "Loading message"))
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
                
                // 載入指示器
                ProgressView()
                    .scaleEffect(1.5)
                    .opacity(showText ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.7)) {
                showLogo = true
            }
            
            withAnimation(
                .spring(duration: 0.7)
                .delay(0.3)
            ) {
                showText = true
            }
            
            withAnimation(
                .linear(duration: 2)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoadingView()
} 