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
    
    // Language configuration
    private let languages = ["zh-Hant", "en", "ja"]
    private let languageNames = [
        NSLocalizedString("language.zh_hant", comment: "Traditional Chinese"),
        NSLocalizedString("language.en", comment: "English"),
        NSLocalizedString("language.ja", comment: "Japanese")
    ]
    
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
            List {
                displaySection
                notificationsSection
                languageSection
                aboutSection
                logoutSection
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: "Settings screen title"))
            .navigationBarItems(trailing: Button(NSLocalizedString("common.done", comment: "Done button")) {
                dismiss()
            })
            .alert(NSLocalizedString("settings.language_changed", comment: "Language change alert title"), isPresented: $needsRestart) {
                Button(NSLocalizedString("common.ok", comment: "OK button"), role: .cancel) {
                    needsRestart = false
                }
            } message: {
                Text(NSLocalizedString("settings.restart_required", comment: "Language change restart message"))
            }
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
        }
    }
    
    // MARK: - Section Views
    private var displaySection: some View {
        Section {
            HStack {
                Label {
                    Text(NSLocalizedString("settings.dark_mode", comment: "Dark mode toggle"))
                } icon: {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .purple : .orange)
                }
                
                Spacer()
                
                Toggle("", isOn: $isDarkMode)
                    .labelsHidden()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isDarkMode.toggle()
                }
            }
        } header: {
            Text(NSLocalizedString("settings.display", comment: "Display settings section"))
        } footer: {
            Text(NSLocalizedString("settings.dark_mode.description", comment: "Dark mode description"))
        }
    }
    
    private var notificationsSection: some View {
        Section {
            HStack {
                Label {
                    Text(NSLocalizedString("settings.enable_notifications", comment: "Enable notifications toggle"))
                } icon: {
                    Image(systemName: notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                        .foregroundColor(notificationsEnabled ? .blue : .gray)
                }
                
                Spacer()
                
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
            }
        } header: {
            Text(NSLocalizedString("settings.notifications", comment: "Notifications settings section"))
        } footer: {
            Text(NSLocalizedString("settings.notifications.description", comment: "Notifications description"))
        }
    }
    
    private var languageSection: some View {
        Section {
            Picker(selection: Binding(
                get: { selectedLanguageIndex },
                set: { newValue in
                    selectedLanguage = languages[newValue]
                    if language != selectedLanguage {
                        language = selectedLanguage
                        needsRestart = true
                    }
                }
            )) {
                ForEach(0..<languageNames.count, id: \.self) { index in
                    HStack {
                        Text(languageNames[index])
                        if languages[index] == language {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .tag(index)
                }
            } label: {
                Label {
                    Text(NSLocalizedString("settings.select_language", comment: "Language selection picker"))
                } icon: {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text(NSLocalizedString("settings.language", comment: "Language settings section"))
        } footer: {
            Text(NSLocalizedString("settings.language.description", comment: "Language settings description"))
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink {
                VersionInfoView()
            } label: {
                Label {
                    HStack {
                        Text(NSLocalizedString("settings.version", comment: "Version label"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label {
                    Text(NSLocalizedString("settings.privacy_policy", comment: "Privacy policy button"))
                } icon: {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.blue)
                }
            }
            
            NavigationLink {
                TermsView()
            } label: {
                Label {
                    Text(NSLocalizedString("settings.terms", comment: "Terms of service button"))
                } icon: {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text(NSLocalizedString("settings.about", comment: "About section"))
        }
    }
    
    private var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                // Perform logout
            } label: {
                Label {
                    Text(NSLocalizedString("settings.logout", comment: "Logout button"))
                } icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
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