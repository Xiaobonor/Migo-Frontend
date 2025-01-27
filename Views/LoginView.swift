import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("歡迎使用 Migo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("專注學習，連結同好")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Google 登入按鈕
            GoogleSignInButton(scheme: .light, style: .wide, state: authService.isLoading ? .disabled : .normal) {
                Task {
                    await authService.signInWithGoogle()
                }
            }
            .frame(width: 280, height: 50)
            
            if let error = authService.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            // 服務條款和隱私政策
            VStack(spacing: 8) {
                Text("登入即表示您同意")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Link("服務條款", destination: URL(string: "https://example.com/terms")!)
                        .font(.caption)
                    
                    Text("和")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Link("隱私政策", destination: URL(string: "https://example.com/privacy")!)
                        .font(.caption)
                }
            }
        }
        .padding()
        .onChange(of: authService.isAuthenticated) { oldValue, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
}

#Preview {
    LoginView()
} 