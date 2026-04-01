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

@MainActor
final class TurnoverAppState: ObservableObject {
    @Published var selectedTab: TurnoverTab = .home
    @Published private(set) var runSession: RunSessionState = .idle
    @Published private(set) var latestCompletedRun: RunSummary?
    @Published private(set) var runHistory: [RunSummary]

    let settings: SettingsSnapshot

    private let trackingService: RunTrackingService
    private let summaryBuilder: any RunSummaryBuilding

    init(
        settings: SettingsSnapshot,
        trackingService: RunTrackingService,
        summaryBuilder: any RunSummaryBuilding,
        runHistory: [RunSummary]
    ) {
        self.settings = settings
        self.trackingService = trackingService
        self.summaryBuilder = summaryBuilder
        self.runHistory = runHistory
        self.latestCompletedRun = runHistory.first

        trackingService.onSnapshot = { [weak self] snapshot in
            Task { @MainActor [weak self] in
                self?.handle(snapshot: snapshot)
            }
        }
    }

    convenience init() {
        self.init(
            settings: TurnoverSampleData.settings,
            trackingService: MockRunTrackingService(),
            summaryBuilder: DefaultRunSummaryBuilder(),
            runHistory: TurnoverSampleData.recentRuns
        )
    }

    func startRun() {
        let startedAt = Date()
        let sessionID = UUID()
        selectedTab = .run
        trackingService.start(settings: settings.runSettings, startedAt: startedAt)

        let snapshot = trackingService.latestSnapshot ?? RunTrackingSnapshot(
            elapsedSeconds: 0,
            movingSeconds: 0,
            distanceMeters: 0,
            currentPaceSecondsPerSplit: nil,
            averagePaceSecondsPerSplit: nil,
            heartRate: nil,
            elevationGainMeters: 0,
            routeShape: []
        )

        runSession = .active(
            ActiveRunSession(
                id: sessionID,
                startedAt: startedAt,
                settings: settings.runSettings,
                snapshot: snapshot
            )
        )
    }

    func pauseRun() {
        guard case .active(let session) = runSession else { return }
        trackingService.pause()
        runSession = .paused(session)
    }

    func resumeRun() {
        guard case .paused(let session) = runSession else { return }
        trackingService.resume()
        runSession = .active(session)
    }

    func finishRun() {
        let session: ActiveRunSession

        switch runSession {
        case .active(let activeSession), .paused(let activeSession):
            session = activeSession
        default:
            return
        }

        trackingService.stop()
        let finalizedSession = ActiveRunSession(
            id: session.id,
            startedAt: session.startedAt,
            settings: session.settings,
            snapshot: trackingService.latestSnapshot ?? session.snapshot
        )
        let run = summaryBuilder.makeSummary(from: finalizedSession, history: runHistory)

        runHistory.insert(run, at: 0)
        latestCompletedRun = run
        runSession = .completed(run)
        selectedTab = .run
    }

    private func handle(snapshot: RunTrackingSnapshot) {
        switch runSession {
        case .active(let session):
            runSession = .active(
                ActiveRunSession(
                    id: session.id,
                    startedAt: session.startedAt,
                    settings: session.settings,
                    snapshot: snapshot
                )
            )
        case .paused, .idle, .completed:
            break
        }
    }
}
