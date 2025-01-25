//
//  ContentView.swift
//  Migo-Frontend
//
//  Created by 洪承佑 on 2025/1/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView {
            FocusView()
                .tabItem {
                    Label(NSLocalizedString("tab.focus", comment: ""), systemImage: "timer")
                }
            
            DiaryView()
                .tabItem {
                    Label(NSLocalizedString("tab.diary", comment: ""), systemImage: "book.fill")
                }
            
            GroupView()
                .tabItem {
                    Label(NSLocalizedString("tab.group", comment: ""), systemImage: "person.3.fill")
                }
            
            GoalsView()
                .tabItem {
                    Label(NSLocalizedString("tab.goals", comment: ""), systemImage: "star.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("tab.profile", comment: ""), systemImage: "person.fill")
                }
        }
        .accentColor(colorScheme == .dark ? .white : .black)
    }
}

#Preview {
    ContentView()
}
