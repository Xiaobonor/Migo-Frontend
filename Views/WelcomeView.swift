import SwiftUI
import GoogleSignInSwift

struct WelcomeView: View {
    // MARK: - Properties
    @StateObject private var authService = AuthenticationService.shared
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var animateBackground = false
    @State private var animateLogo = false
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButton = false
    @State private var animateLinks = false
    @State private var isButtonPressed = false
    
    // MARK: - Animation Properties
    private let backgroundAnimation = Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)
    private let springAnimation = Animation.spring(response: 0.6, dampingFraction: 0.7)
    
    // MARK: - Custom Button Style
    private var googleSignInButton: some View {
        Button {
            // 點擊動畫
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isButtonPressed = true
            }
            
            // 延遲執行登入操作，讓動畫有時間完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isButtonPressed = false
                }
                Task {
                    do {
                        // 開始登入動畫
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authService.isLoading = true
                        }
                        
                        await authService.signInWithGoogle()
                        
                        // 登入成功動畫
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            authService.isLoading = false
                        }
                    } catch {
                        // 登入失敗動畫
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            authService.isLoading = false
                        }
                    }
                }
            }
        } label: {
            ZStack {
                // 背景容器
                RoundedRectangle(cornerRadius: 28)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(.systemGray5), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
                    .overlay(
                        // 漸層光暈效果
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.8),
                                        .white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 1)
                    )
                
                if authService.isLoading {
                    // 載入動畫
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    // 按鈕內容
                    HStack(spacing: 12) {
                        GoogleLogoView()
                            .frame(width: 20, height: 20)
                        
                        Text(NSLocalizedString("welcome.login.google", comment: ""))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .frame(width: UIScreen.main.bounds.width - 48, height: 56)
            .scaleEffect(isButtonPressed ? 0.97 : 1)
            .scaleEffect(authService.isLoading ? 0.98 : 1)
            .opacity(authService.isLoading ? 0.8 : 1)
        }
        .disabled(authService.isLoading)
        .scaleEffect(animateButton ? 1 : 0.8)
        .opacity(animateButton ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.9), value: animateButton)
        
        // 錯誤訊息
        .overlay(alignment: .bottom) {
            if let error = authService.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .offset(y: 48)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: error)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 動態背景
            Color(AppColors.background)
                .ignoresSafeArea()
            
            // 動態漸層背景
            GeometryReader { geometry in
                ZStack {
                    // 第一個圓形
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.migoColor.opacity(0.2),
                                    AppColors.migoColor.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 1.2)
                        .offset(
                            x: animateBackground ? geometry.size.width * 0.2 : -geometry.size.width * 0.2,
                            y: animateBackground ? -geometry.size.height * 0.1 : geometry.size.height * 0.1
                        )
                        .blur(radius: 60)
                    
                    // 第二個圓形
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.accent.opacity(0.2),
                                    AppColors.accent.opacity(0.1)
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .frame(width: geometry.size.width)
                        .offset(
                            x: animateBackground ? -geometry.size.width * 0.2 : geometry.size.width * 0.2,
                            y: animateBackground ? geometry.size.height * 0.1 : -geometry.size.height * 0.1
                        )
                        .blur(radius: 60)
                }
                .animation(backgroundAnimation, value: animateBackground)
            }
            
            // 主要內容
            VStack(spacing: 32) {
                Spacer()
                
                // Logo 和標題
                VStack(spacing: 24) {
                    // Logo
                    ZStack {
                        // 光暈效果
                        ForEach(0..<3) { i in
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 90))
                                .foregroundColor(AppColors.migoColor.opacity(0.3))
                                .blur(radius: CGFloat(i * 4))
                                .scaleEffect(animateLogo ? 1.1 : 0.9)
                                .animation(
                                    Animation.easeInOut(duration: 2)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.3),
                                    value: animateLogo
                                )
                        }
                        
                        // 主 Logo
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.migoColor)
                            .symbolEffect(.bounce, options: .repeating)
                            .scaleEffect(animateLogo ? 1 : 0.5)
                            .opacity(animateLogo ? 1 : 0)
                            .animation(springAnimation.delay(0.3), value: animateLogo)
                    }
                    
                    VStack(spacing: 12) {
                        // 主標題
                        Text(NSLocalizedString("welcome.title", comment: ""))
                            .font(.appTitle())
                            .foregroundColor(AppColors.text)
                            .offset(y: animateTitle ? 0 : 20)
                            .opacity(animateTitle ? 1 : 0)
                            .animation(springAnimation.delay(0.5), value: animateTitle)
                        
                        // 副標題
                        Text(NSLocalizedString("welcome.subtitle", comment: ""))
                            .font(.appHeadline())
                            .foregroundColor(AppColors.textSecondary)
                            .offset(y: animateSubtitle ? 0 : 20)
                            .opacity(animateSubtitle ? 1 : 0)
                            .animation(springAnimation.delay(0.7), value: animateSubtitle)
                    }
                }
                .padding(.bottom, 60)
                
                // 登入按鈕
                googleSignInButton
                
                Spacer()
                
                // 隱私政策和服務條款
                HStack(spacing: 20) {
                    Button(NSLocalizedString("welcome.privacy_policy", comment: "")) {
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(AppColors.migoColor)
                    .contentShape(Rectangle())
                    
                    Text("•")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(NSLocalizedString("welcome.terms", comment: "")) {
                        showingTerms = true
                    }
                    .foregroundColor(AppColors.migoColor)
                    .contentShape(Rectangle())
                }
                .font(.appCaption())
                .padding(.bottom, 16)
                .offset(y: animateLinks ? 0 : 20)
                .opacity(animateLinks ? 1 : 0)
                .animation(springAnimation.delay(1.1), value: animateLinks)
            }
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
            // 啟動所有動畫
            withAnimation(backgroundAnimation) {
                animateBackground = true
            }
            animateLogo = true
            animateTitle = true
            animateSubtitle = true
            animateButton = true
            animateLinks = true
        }
    }
}

// MARK: - Google Logo View
struct GoogleLogoView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let middle = size / 2
            let strokeWidth = size * 0.08
            let circleRadius = size * 0.38
            
            Path { path in
                // 藍色部分
                path.move(to: CGPoint(x: middle + circleRadius * cos(.pi/6), y: middle - circleRadius * sin(.pi/6)))
                path.addArc(
                    center: CGPoint(x: middle, y: middle),
                    radius: circleRadius,
                    startAngle: .degrees(30),
                    endAngle: .degrees(150),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: middle + circleRadius * cos(5 * .pi/6), y: middle + circleRadius * sin(5 * .pi/6)))
            }
            .stroke(Color(red: 66/255, green: 133/255, blue: 244/255), lineWidth: strokeWidth)
            
            Path { path in
                // 綠色部分
                path.move(to: CGPoint(x: middle + circleRadius * cos(5 * .pi/6), y: middle + circleRadius * sin(5 * .pi/6)))
                path.addArc(
                    center: CGPoint(x: middle, y: middle),
                    radius: circleRadius,
                    startAngle: .degrees(150),
                    endAngle: .degrees(210),
                    clockwise: false
                )
            }
            .stroke(Color(red: 52/255, green: 168/255, blue: 83/255), lineWidth: strokeWidth)
            
            Path { path in
                // 黃色部分
                path.move(to: CGPoint(x: middle - circleRadius * cos(.pi/6), y: middle + circleRadius * sin(.pi/6)))
                path.addArc(
                    center: CGPoint(x: middle, y: middle),
                    radius: circleRadius,
                    startAngle: .degrees(210),
                    endAngle: .degrees(330),
                    clockwise: false
                )
            }
            .stroke(Color(red: 251/255, green: 188/255, blue: 5/255), lineWidth: strokeWidth)
            
            Path { path in
                // 紅色部分
                path.move(to: CGPoint(x: middle + circleRadius * cos(11 * .pi/6), y: middle - circleRadius * sin(11 * .pi/6)))
                path.addArc(
                    center: CGPoint(x: middle, y: middle),
                    radius: circleRadius,
                    startAngle: .degrees(330),
                    endAngle: .degrees(30),
                    clockwise: false
                )
            }
            .stroke(Color(red: 234/255, green: 67/255, blue: 53/255), lineWidth: strokeWidth)
            
            // 右側延伸部分
            Path { path in
                let startPoint = CGPoint(x: middle + circleRadius * cos(.pi/6), y: middle - circleRadius * sin(.pi/6))
                path.move(to: startPoint)
                path.addLine(to: CGPoint(x: size * 0.95, y: middle))
            }
            .stroke(Color(red: 66/255, green: 133/255, blue: 244/255), lineWidth: strokeWidth)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// 預覽 Google Logo
struct GoogleLogoView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleLogoView()
            .frame(width: 100, height: 100)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

#Preview {
    WelcomeView()
} 