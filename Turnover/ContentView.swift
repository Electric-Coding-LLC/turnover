//
//  ContentView.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            LiveRunScreen()
                .tabItem {
                    Label("Run", systemImage: "figure.run")
                }

            HistoryScreen()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }

            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .preferredColorScheme(.dark)
        .tint(TurnoverPalette.accent)
    }
}

#Preview {
    ContentView()
}
