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
    @Published private(set) var historyMetrics: RunHistoryMetrics

    let settings: SettingsSnapshot
    let platformStatus: RunPlatformStatus

    private let trackingService: RunTrackingService
    private let metricsCalculator: any RunMetricsCalculating
    private let summaryBuilder: any RunSummaryBuilding
    private let historyReader: any RunHistoryReading
    private let finalizedRunWriter: any FinalizedRunWriting

    init(
        settings: SettingsSnapshot,
        trackingService: RunTrackingService,
        metricsCalculator: any RunMetricsCalculating,
        summaryBuilder: any RunSummaryBuilding,
        runHistory: [RunSummary],
        platformStatus: RunPlatformStatus,
        historyReader: any RunHistoryReading,
        finalizedRunWriter: any FinalizedRunWriting
    ) {
        self.settings = settings
        self.trackingService = trackingService
        self.metricsCalculator = metricsCalculator
        self.summaryBuilder = summaryBuilder
        self.runHistory = runHistory
        self.latestCompletedRun = runHistory.first
        self.historyMetrics = metricsCalculator.summarizeHistory(runHistory, using: settings.runSettings, now: Date())
        self.platformStatus = platformStatus
        self.historyReader = historyReader
        self.finalizedRunWriter = finalizedRunWriter

        trackingService.onSnapshot = { [weak self] snapshot in
            Task { @MainActor [weak self] in
                self?.handle(snapshot: snapshot)
            }
        }
    }

    convenience init() {
        let dependencies = TurnoverAppDependencies.inMemory()
        let settings = dependencies.settingsReader.readSettings()
        let metricsCalculator = DefaultRunMetricsCalculator()

        self.init(
            settings: settings,
            trackingService: MockRunTrackingService(),
            metricsCalculator: metricsCalculator,
            summaryBuilder: DefaultRunSummaryBuilder(metricsCalculator: metricsCalculator),
            runHistory: dependencies.historyReader.readRunHistory(),
            platformStatus: dependencies.platformStatusProvider.currentPlatformStatus(),
            historyReader: dependencies.historyReader,
            finalizedRunWriter: dependencies.finalizedRunWriter
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
        let payload = FinalizedRunPayload(session: finalizedSession, summary: run)
        finalizedRunWriter.writeFinalizedRun(payload)
        runHistory = historyReader.readRunHistory()
        latestCompletedRun = run
        runSession = .completed(run)
        historyMetrics = metricsCalculator.summarizeHistory(runHistory, using: settings.runSettings, now: Date())
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
