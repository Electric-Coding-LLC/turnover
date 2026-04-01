//
//  ContentView.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = TurnoverAppState()
    @State private var homePath: [RunSummary] = []
    @State private var historyPath: [RunSummary] = []
    @State private var runPath: [RunDestination] = []

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $homePath) {
                HomeScreen(onStartRun: startRun)
                    .navigationDestination(for: RunSummary.self) { run in
                        RunDetailScreen(run: run)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(TurnoverTab.home)

            NavigationStack(path: $runPath) {
                LiveRunScreen(
                    sessionPhase: appState.runSessionPhase,
                    latestCompletedRun: appState.latestCompletedRun,
                    onStartRun: startRun,
                    onPauseRun: appState.pauseRun,
                    onResumeRun: appState.resumeRun,
                    onFinishRun: finishRun,
                    onViewLatestRun: showLatestCompletedRun
                )
                .navigationDestination(for: RunDestination.self) { destination in
                    switch destination {
                    case .summary(let run):
                        RunDetailScreen(run: run)
                    }
                }
            }
            .tabItem {
                Label("Run", systemImage: "figure.run")
            }
            .tag(TurnoverTab.run)

            NavigationStack(path: $historyPath) {
                HistoryScreen()
                    .navigationDestination(for: RunSummary.self) { run in
                        RunDetailScreen(run: run)
                    }
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
            }
            .tag(TurnoverTab.history)

            NavigationStack {
                SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
            }
            .tag(TurnoverTab.settings)
        }
        .preferredColorScheme(.dark)
        .tint(TurnoverPalette.accent)
    }

    private func startRun() {
        runPath.removeAll()
        appState.startRun()
    }

    private func finishRun() {
        let completedRun = TurnoverSampleData.featuredRun
        runPath = [.summary(completedRun)]
        appState.finishRun(with: completedRun)
    }

    private func showLatestCompletedRun() {
        guard let latestCompletedRun = appState.latestCompletedRun else { return }
        runPath = [.summary(latestCompletedRun)]
        appState.selectedTab = .run
    }
}

private enum RunDestination: Hashable {
    case summary(RunSummary)
}

#Preview {
    ContentView()
}
