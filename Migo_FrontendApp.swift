import SwiftUI
import Foundation

// MARK: - Main App Entry Point
@main
struct Migo_FrontendApp: App {
    // MARK: - Properties
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language: String = {
        // Get system language
        let systemLanguage = Locale.current.languageCode ?? "en"
        // Check if system language is supported
        let supportedLanguages = ["zh-Hant", "en", "ja"]
        if systemLanguage == "zh" {
            return "zh-Hant"
        } else if supportedLanguages.contains(systemLanguage) {
            return systemLanguage
        }
        return "en"
    }()
    
    // MARK: - Initialization
    init() {
        // Set default language for the app
        UserDefaults.standard.register(defaults: ["language": language])
        
        // Force update language settings
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Set up localization bundle
        if let languageBundlePath = Bundle.main.path(forResource: language, ofType: "lproj"),
           let languageBundle = Bundle(path: languageBundlePath) {
            Bundle.main.localizations.forEach { _ in }
            Bundle.main.preferredLocalizations.forEach { _ in }
        }
    }
    
    // MARK: - Scene Configuration
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.locale, Locale(identifier: language))
                .onAppear {
                    // Ensure language settings are correctly applied on each launch
                    UserDefaults.standard.set([language], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                }
        }
    }
}
