import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var isDarkMode: Bool
    @AppStorage("language") private var language = "zh-Hant"
    @State private var notificationsEnabled = true
    @State private var needsRestart = false
    @State private var selectedLanguage: String
    @State private var showingLanguageSheet = false
    @State private var showingLogoutAlert = false
    @State private var selectedSection: String? = nil
    @State private var animateBackground = false
    @State private var showingLoginSheet = false
    @StateObject private var authService = AuthenticationService.shared
    
    // Language configuration
    private let languages = ["zh-Hant", "en"]
    private let languageNames = [
        NSLocalizedString("language.zh_hant", comment: "Traditional Chinese"),
        NSLocalizedString("language.en", comment: "English")
    ]
    
    // MARK: - Animation Properties
    @Namespace private var animation
    
    // MARK: - Initialization
    init(isDarkMode: Binding<Bool>) {
        self._isDarkMode = isDarkMode
        self._selectedLanguage = State(initialValue: UserDefaults.standard.string(forKey: "language") ?? "zh-Hant")
    }
    
    private var selectedLanguageIndex: Int {
        languages.firstIndex(of: selectedLanguage) ?? 0
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                Color(isDarkMode ? .systemBackground : .secondarySystemBackground)
                    .ignoresSafeArea()
                    .overlay(
                        GeometryReader { geometry in
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: geometry.size.width * 0.8)
                                .offset(x: animateBackground ? geometry.size.width * 0.3 : -geometry.size.width * 0.3,
                                      y: animateBackground ? geometry.size.height * 0.2 : geometry.size.height * 0.4)
                                .blur(radius: 50)
                            
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: geometry.size.width * 0.6)
                                .offset(x: animateBackground ? -geometry.size.width * 0.2 : geometry.size.width * 0.2,
                                      y: animateBackground ? geometry.size.height * 0.4 : geometry.size.height * 0.2)
                                .blur(radius: 50)
                        }
                    )
                    .animation(.default, value: isDarkMode)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        profileSection
                        
                        // Main Settings
                        settingsSection
                        
                        // About Section
                        aboutSection
                        
                        // Login/Logout Button
                        if authService.isAuthenticated {
                            logoutButton
                        } else {
                            loginButton
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: "Settings screen title"))
            .navigationBarItems(trailing: Button(NSLocalizedString("common.done", comment: "Done button")) {
                dismiss()
            })
            .sheet(isPresented: $showingLanguageSheet) {
                languageSelectionSheet
            }
            .sheet(isPresented: $showingLoginSheet) {
                LoginView()
            }
            .alert(NSLocalizedString("settings.logout", comment: "Logout"), isPresented: $showingLogoutAlert) {
                Button(NSLocalizedString("common.cancel", comment: "Cancel button"), role: .cancel) {}
                Button(NSLocalizedString("settings.logout", comment: "Logout button"), role: .destructive) {
                    authService.signOut()
                    
                    // 等待登出動畫完成
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        authService.handleSignOutAnimationComplete()
                    }
                }
            } message: {
                Text(NSLocalizedString("settings.logout_confirmation", comment: "Logout confirmation message"))
            }
            .alert(NSLocalizedString("settings.language_changed", comment: "Language changed"), isPresented: $needsRestart) {
                Button(NSLocalizedString("common.ok", comment: "OK button"), role: .cancel) {
                    needsRestart = false
                }
            } message: {
                Text(NSLocalizedString("settings.restart_required", comment: "Restart required message"))
            }
        }
        .onAppear {
            // 設置登出時關閉彈出視窗的回調
            authService.onClosePopup = {
                dismiss()
            }
            
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateBackground = true
            }
        }
        .onDisappear {
            // 清除回調避免記憶體洩漏
            authService.onClosePopup = nil
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack {
            if let user = authService.currentUser {
                AsyncImage(url: user.picture) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
                
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                
                Text("尚未登入")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("登入以使用完整功能")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 16) {
            SettingsCard(
                title: NSLocalizedString("settings.display", comment: "Display settings"),
                icon: "paintbrush.fill",
                color: .blue
            ) {
                // Dark Mode Toggle
                SettingsRow(
                    title: NSLocalizedString("settings.dark_mode", comment: "Dark mode"),
                    icon: "moon.fill",
                    color: .purple
                ) {
                    Toggle("", isOn: $isDarkMode)
                        .labelsHidden()
                }
                
                // Language Selection
                SettingsRow(
                    title: NSLocalizedString("settings.language", comment: "Language"),
                    icon: "globe",
                    color: .green,
                    showDivider: false
                ) {
                    HStack {
                        Text(NSLocalizedString(languages.first { $0 == language } ?? "", comment: "Language name"))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        showingLanguageSheet = true
                    }
                }
            }
            
            SettingsCard(
                title: NSLocalizedString("settings.notifications", comment: "Notifications"),
                icon: "bell.fill",
                color: .red
            ) {
                SettingsRow(
                    title: NSLocalizedString("settings.enable_notifications", comment: "Enable notifications"),
                    icon: "bell.badge.fill",
                    color: .red,
                    showDivider: false
                ) {
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        SettingsCard(
            title: NSLocalizedString("settings.about", comment: "About"),
            icon: "info.circle.fill",
            color: .orange
        ) {
            NavigationLink(destination: LegalDocumentView(documentType: .privacyPolicy)) {
                SettingsRow(
                    title: NSLocalizedString("settings.privacy_policy", comment: "Privacy policy"),
                    icon: "lock.fill",
                    color: .blue
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: LegalDocumentView(documentType: .terms)) {
                SettingsRow(
                    title: NSLocalizedString("settings.terms", comment: "Terms of service"),
                    icon: "doc.text.fill",
                    color: .green
                ) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            SettingsRow(
                title: NSLocalizedString("settings.version", comment: "Version"),
                icon: "number.circle.fill",
                color: .purple,
                showDivider: false
            ) {
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: { showingLoginSheet = true }) {
            HStack {
                Image(systemName: "person.fill.badge.plus")
                    .foregroundColor(.blue)
                Text(NSLocalizedString("settings.login", comment: "Login"))
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { showingLogoutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                Text(NSLocalizedString("settings.logout", comment: "Logout"))
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red.opacity(0.1))
            )
        }
    }
    
    // MARK: - Language Selection Sheet
    private var languageSelectionSheet: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.self) { languageCode in
                    Button(action: {
                        if language != languageCode {
                            language = languageCode
                            needsRestart = true
                        }
                        showingLanguageSheet = false
                    }) {
                        HStack {
                            Text(NSLocalizedString(languageNames[languages.firstIndex(of: languageCode) ?? 0], comment: "Language name"))
                            Spacer()
                            if language == languageCode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle(NSLocalizedString("settings.select_language", comment: "Select language"))
            .navigationBarItems(trailing: Button(NSLocalizedString("common.done", comment: "Done button")) {
                showingLanguageSheet = false
            })
        }
    }
}

// MARK: - Settings Card
struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            content
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let showDivider: Bool
    let content: Content
    
    init(
        title: String,
        icon: String,
        color: Color,
        showDivider: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.showDivider = showDivider
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                
                Spacer()
                
                content
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            
            if showDivider {
                Divider()
                    .padding(.leading, 52)
            }
        }
    }
}

// MARK: - Supporting Views
struct VersionInfoView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text(NSLocalizedString("settings.version", comment: ""))
                    Spacer()
                    Text("1.0.0")
                }
                
                HStack {
                    Text(NSLocalizedString("settings.build", comment: ""))
                    Spacer()
                    Text("2025012501")
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings.version_info", comment: ""))
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text(NSLocalizedString("settings.privacy_policy.content", comment: ""))
                .padding()
        }
        .navigationTitle(NSLocalizedString("settings.privacy_policy", comment: ""))
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text(NSLocalizedString("settings.terms.content", comment: ""))
                .padding()
        }
        .navigationTitle(NSLocalizedString("settings.terms", comment: ""))
    }
}

// MARK: - Preview Provider
#Preview {
    SettingsView(isDarkMode: .constant(false))
} 
