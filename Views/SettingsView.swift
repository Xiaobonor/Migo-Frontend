import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isDarkMode: Bool
    @AppStorage("language") private var language = "zh-Hant"
    @State private var notificationsEnabled = true
    @State private var needsRestart = false
    @State private var selectedLanguage: String
    
    private let languages = ["zh-Hant", "en", "ja"]
    private let languageNames = ["繁體中文", "English", "日本語"]
    
    init(isDarkMode: Binding<Bool>) {
        self._isDarkMode = isDarkMode
        self._selectedLanguage = State(initialValue: UserDefaults.standard.string(forKey: "language") ?? "zh-Hant")
    }
    
    private var selectedLanguageIndex: Int {
        languages.firstIndex(of: selectedLanguage) ?? 0
    }
    
    var body: some View {
        NavigationView {
            Form {
                displaySection
                notificationsSection
                languageSection
                aboutSection
                logoutSection
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: ""))
            .navigationBarItems(trailing: Button(NSLocalizedString("common.done", comment: "")) {
                if language != selectedLanguage {
                    language = selectedLanguage
                    needsRestart = true
                }
                dismiss()
            })
            .alert(NSLocalizedString("settings.language_changed", comment: ""), isPresented: $needsRestart) {
                Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {
                    needsRestart = false
                }
            } message: {
                Text(NSLocalizedString("settings.restart_required", comment: ""))
            }
        }
    }
    
    private var displaySection: some View {
        Section(header: Text(NSLocalizedString("settings.display", comment: ""))) {
            Toggle(NSLocalizedString("settings.dark_mode", comment: ""), isOn: $isDarkMode)
        }
    }
    
    private var notificationsSection: some View {
        Section(header: Text(NSLocalizedString("settings.notifications", comment: ""))) {
            Toggle(NSLocalizedString("settings.enable_notifications", comment: ""), isOn: $notificationsEnabled)
        }
    }
    
    private var languageSection: some View {
        Section(header: Text(NSLocalizedString("settings.language", comment: ""))) {
            Picker(NSLocalizedString("settings.select_language", comment: ""), selection: Binding(
                get: { selectedLanguageIndex },
                set: { newValue in
                    selectedLanguage = languages[newValue]
                }
            )) {
                ForEach(0..<languageNames.count, id: \.self) { index in
                    Text(languageNames[index]).tag(index)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section(header: Text(NSLocalizedString("settings.about", comment: ""))) {
            HStack {
                Text(NSLocalizedString("settings.version", comment: ""))
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.gray)
            }
            
            Button(NSLocalizedString("settings.privacy_policy", comment: "")) {
                // 打開隱私政策
            }
            
            Button(NSLocalizedString("settings.terms", comment: "")) {
                // 打開服務條款
            }
        }
    }
    
    private var logoutSection: some View {
        Section {
            Button(NSLocalizedString("settings.logout", comment: "")) {
                // 登出操作
            }
            .foregroundColor(.red)
        }
    }
}

#Preview {
    SettingsView(isDarkMode: .constant(false))
} 