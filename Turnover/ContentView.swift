//
//  ContentView.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState: TurnoverAppState
    @State private var homePath: [RunSummary] = []
    @State private var historyPath: [RunSummary] = []
    @State private var runPath: [RunDestination] = []

    @MainActor
    init(appState: TurnoverAppState? = nil) {
        _appState = StateObject(wrappedValue: appState ?? TurnoverAppState())
    }

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $homePath) {
                HomeScreen(
                    featuredRun: appState.runHistory.first,
                    historyMetrics: appState.historyMetrics,
                    onStartRun: startRun
                )
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
                    runSession: appState.runSession,
                    latestCompletedRun: appState.latestCompletedRun,
                    settings: appState.settings,
                    platformStatus: appState.platformStatus,
                    onStartRun: startRun,
                    onPauseRun: appState.pauseRun,
                    onResumeRun: appState.resumeRun,
                    onFinishRun: finishRun,
                    onViewLatestRun: showLatestCompletedRun,
                    onOpenSettings: appState.openPlatformSettings
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
                HistoryScreen(runs: appState.runHistory, historyMetrics: appState.historyMetrics)
                    .navigationDestination(for: RunSummary.self) { run in
                        RunDetailScreen(run: run)
                    }
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
            }
            .tag(TurnoverTab.history)

            NavigationStack {
                SettingsScreen(
                    settings: appState.settings,
                    onUpdateSettings: appState.updateSettings
                )
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
            }
            .tag(TurnoverTab.settings)
        }
        .preferredColorScheme(.dark)
        .tint(TurnoverPalette.accent)
        .task {
            appState.refreshPlatformStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            appState.refreshPlatformStatus()
        }
    }

    private func startRun() {
        runPath.removeAll()
        appState.startRun()
    }

    private func finishRun() {
        appState.finishRun()
        if let completedRun = appState.latestCompletedRun {
            runPath = [.summary(completedRun)]
        }
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
    ContentView(appState: TurnoverAppState.preview())
}
