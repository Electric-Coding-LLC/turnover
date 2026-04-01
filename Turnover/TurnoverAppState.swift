//
//  TurnoverAppState.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import Combine
import Foundation

enum TurnoverTab: Hashable {
    case home
    case run
    case history
    case settings
}

enum RunSessionPhase: Equatable {
    case idle
    case active
    case paused
    case completed
}

final class TurnoverAppState: ObservableObject {
    @Published var selectedTab: TurnoverTab = .home
    @Published var runSessionPhase: RunSessionPhase = .idle
    @Published var latestCompletedRun: RunSummary?

    func startRun() {
        runSessionPhase = .active
        selectedTab = .run
    }

    func pauseRun() {
        guard runSessionPhase == .active else { return }
        runSessionPhase = .paused
    }

    func resumeRun() {
        guard runSessionPhase == .paused else { return }
        runSessionPhase = .active
    }

    func finishRun(with run: RunSummary) {
        latestCompletedRun = run
        runSessionPhase = .completed
        selectedTab = .run
    }
}
