//
//  Migo_FrontendApp.swift
//  Migo-Frontend
//
//  Created by 洪承佑 on 2025/1/25.
//

import SwiftUI

@main
struct Migo_FrontendApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("language") private var language: String = {
        // 獲取系統語言
        let systemLanguage = Locale.current.languageCode ?? "en"
        // 檢查系統語言是否在我們支援的語言列表中
        let supportedLanguages = ["zh-Hant", "en", "ja"]
        if systemLanguage == "zh" {
            return "zh-Hant"
        } else if supportedLanguages.contains(systemLanguage) {
            return systemLanguage
        }
        return "en"
    }()
    
    init() {
        // 設置應用程序的預設語言
        UserDefaults.standard.register(defaults: ["language": language])
        
        // 強制更新語言設置
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 設置本地化 Bundle
        if let languageBundlePath = Bundle.main.path(forResource: language, ofType: "lproj"),
           let languageBundle = Bundle(path: languageBundlePath) {
            Bundle.main.localizations.forEach { _ in }
            Bundle.main.preferredLocalizations.forEach { _ in }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(\.locale, Locale(identifier: language))
                .onAppear {
                    // 確保語言設置在每次啟動時都被正確應用
                    UserDefaults.standard.set([language], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                }
        }
    }
}
