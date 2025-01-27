import SwiftUI
import GoogleSignInSwift

struct WelcomeView: View {
    // MARK: - Properties
    @StateObject private var authService = AuthenticationService.shared
    @State private var showingLoginSheet = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var animateBackground = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 動態背景
            Color(AppColors.background)
                .ignoresSafeArea()
                .overlay(
                    GeometryReader { geometry in
                        Circle()
                            .fill(AppColors.migoColor.opacity(0.1))
                            .frame(width: geometry.size.width * 0.8)
                            .offset(x: animateBackground ? geometry.size.width * 0.3 : -geometry.size.width * 0.3,
                                  y: animateBackground ? geometry.size.height * 0.2 : geometry.size.height * 0.4)
                            .blur(radius: 50)
                        
                        Circle()
                            .fill(AppColors.accent.opacity(0.1))
                            .frame(width: geometry.size.width * 0.6)
                            .offset(x: animateBackground ? -geometry.size.width * 0.2 : geometry.size.width * 0.2,
                                  y: animateBackground ? geometry.size.height * 0.4 : geometry.size.height * 0.2)
                            .blur(radius: 50)
                    }
                )
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo 和標題
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.migoColor)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("歡迎來到 Migo")
                        .font(.appTitle())
                        .foregroundColor(AppColors.text)
                    
                    Text("開始你的學習之旅")
                        .font(.appHeadline())
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 60)
                
                // 登入按鈕
                Button(action: { showingLoginSheet = true }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("登入")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.migoColor)
                    .foregroundColor(.white)
                    .cornerRadius(AppDimensions.cornerRadius)
                    .shadow(color: AppColors.migoColor.opacity(0.3),
                           radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 隱私政策和服務條款
                HStack(spacing: 20) {
                    Button("隱私政策") {
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(AppColors.migoColor)
                    
                    Text("•")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button("服務條款") {
                        showingTerms = true
                    }
                    .foregroundColor(AppColors.migoColor)
                }
                .font(.appCaption())
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showingLoginSheet) {
            LoginView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            NavigationView {
                LegalDocumentView(documentType: .privacyPolicy)
            }
        }
        .sheet(isPresented: $showingTerms) {
            NavigationView {
                LegalDocumentView(documentType: .terms)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
    }
}

#Preview {
    WelcomeView()
} 