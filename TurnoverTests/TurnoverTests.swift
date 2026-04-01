//
//  TurnoverTests.swift
//  TurnoverTests
//
//  Created by iamce on 3/31/26.
//

import Foundation
import Testing
@testable import Turnover

@MainActor
struct TurnoverTests {

    @Test func appStateFinishesRunIntoCompletedSummary() async throws {
        let trackingService = StubRunTrackingService(snapshot: .finished)
        let summaryBuilder = StubRunSummaryBuilder()
        let metricsCalculator = DefaultRunMetricsCalculator()
        let historyStore = InMemoryRunHistoryStore(seedRuns: TurnoverSampleData.recentRuns)
        let platformStatusProvider = StubRunPlatformStatusProvider()
        let appState = TurnoverAppState(
            settings: TurnoverSampleData.settings,
            trackingService: trackingService,
            metricsCalculator: metricsCalculator,
            summaryBuilder: summaryBuilder,
            runHistory: historyStore.readRunHistory(),
            platformStatusProvider: platformStatusProvider,
            historyReader: historyStore,
            finalizedRunWriter: historyStore
        )

        appState.startRun()
        appState.finishRun()

        #expect(appState.latestCompletedRun?.title == "Built Run")
        #expect(appState.runHistory.first?.title == "Built Run")

        guard case .completed(let run) = appState.runSession else {
            Issue.record("Expected completed run session")
            return
        }

        #expect(run.title == "Built Run")
    }

    @Test func appStatePausesAndResumesActiveSession() async throws {
        let trackingService = StubRunTrackingService(snapshot: .running)
        let historyStore = InMemoryRunHistoryStore(seedRuns: TurnoverSampleData.recentRuns)
        let platformStatusProvider = StubRunPlatformStatusProvider()
        let appState = TurnoverAppState(
            settings: TurnoverSampleData.settings,
            trackingService: trackingService,
            metricsCalculator: DefaultRunMetricsCalculator(),
            summaryBuilder: StubRunSummaryBuilder(),
            runHistory: historyStore.readRunHistory(),
            platformStatusProvider: platformStatusProvider,
            historyReader: historyStore,
            finalizedRunWriter: historyStore
        )

        appState.startRun()
        appState.pauseRun()

        guard case .paused = appState.runSession else {
            Issue.record("Expected paused run session")
            return
        }

        #expect(trackingService.pauseCallCount == 1)

        appState.resumeRun()

        guard case .active = appState.runSession else {
            Issue.record("Expected active run session after resume")
            return
        }

        #expect(trackingService.resumeCallCount == 1)
    }

    @Test func historyMetricsSummarizeRecentRunsAndRecords() async throws {
        let metrics = DefaultRunMetricsCalculator().summarizeHistory(
            TurnoverSampleData.recentRuns,
            using: TurnoverSampleData.settings.runSettings,
            now: TurnoverSampleData.featuredRun.startedAt
        )

        #expect(metrics.runCount == 3)
        #expect(metrics.personalRecordCount == 2)
        #expect(metrics.weeklyDistanceMeters == 13_560)
        #expect(metrics.monthlyDistanceMeters == 30_360)
        #expect(metrics.latestRunDistanceMeters == 8_420)
        #expect(metrics.personalRecords.map(\.label) == ["Mile", "5K"])
    }

    @Test func localSettingsStoreReadsSeedAndPersistsWrites() async throws {
        let directory = makeTemporaryDirectory()
        let store = LocalSettingsStore(baseDirectory: directory)

        #expect(store.readSettings().distanceUnit == .kilometers)

        let updatedSettings = SettingsSnapshot(
            distanceUnit: .miles,
            splitUnit: .mile,
            autoPauseEnabled: false,
            zoneMethod: .percentOfMaxHeartRate,
            maxHeartRate: 185,
            version: "0.1.1"
        )

        store.writeSettings(updatedSettings)

        let reloadedStore = LocalSettingsStore(baseDirectory: directory)
        let reloadedSettings = reloadedStore.readSettings()

        #expect(reloadedSettings.distanceUnit == .miles)
        #expect(reloadedSettings.splitUnit == .mile)
        #expect(reloadedSettings.autoPauseEnabled == false)
        #expect(reloadedSettings.maxHeartRate == 185)
        #expect(reloadedSettings.version == "0.1.1")
    }

    @Test func localRunHistoryStoreSeedsAndPersistsFinishedRuns() async throws {
        let directory = makeTemporaryDirectory()
        let store = LocalRunHistoryStore(baseDirectory: directory)

        #expect(store.readRunHistory().count == TurnoverSampleData.recentRuns.count)

        let newRun = StubRunSummaryBuilder().makeSummary(
            from: ActiveRunSession(
                id: UUID(),
                startedAt: Date(timeIntervalSince1970: 42),
                settings: TurnoverSampleData.settings.runSettings,
                snapshot: .finished
            ),
            history: []
        )

        store.writeFinalizedRun(
            FinalizedRunPayload(
                session: ActiveRunSession(
                    id: newRun.id,
                    startedAt: newRun.startedAt,
                    settings: TurnoverSampleData.settings.runSettings,
                    snapshot: .finished
                ),
                summary: newRun
            )
        )

        let reloadedStore = LocalRunHistoryStore(baseDirectory: directory)
        let persistedHistory = reloadedStore.readRunHistory()

        #expect(persistedHistory.count == TurnoverSampleData.recentRuns.count + 1)
        #expect(persistedHistory.first?.title == "Built Run")
        #expect(persistedHistory.first?.distanceMeters == 5_000)
    }

    @Test func appStateRefreshesPlatformStatusFromProvider() async throws {
        let trackingService = StubRunTrackingService(snapshot: .running)
        let historyStore = InMemoryRunHistoryStore(seedRuns: TurnoverSampleData.recentRuns)
        let platformStatusProvider = StubRunPlatformStatusProvider(
            status: RunPlatformStatus(
                trackingAuthorization: .notDetermined,
                trackingAvailability: .available,
                heartRateAvailability: .unavailable
            )
        )
        let appState = TurnoverAppState(
            settings: TurnoverSampleData.settings,
            trackingService: trackingService,
            metricsCalculator: DefaultRunMetricsCalculator(),
            summaryBuilder: StubRunSummaryBuilder(),
            runHistory: historyStore.readRunHistory(),
            platformStatusProvider: platformStatusProvider,
            historyReader: historyStore,
            finalizedRunWriter: historyStore
        )

        #expect(appState.platformStatus.trackingAuthorization == .notDetermined)

        platformStatusProvider.updateStatus(
            RunPlatformStatus(
                trackingAuthorization: .authorized,
                trackingAvailability: .available,
                heartRateAvailability: .unavailable
            )
        )

        await Task.yield()

        #expect(appState.platformStatus.trackingAuthorization == .authorized)

        appState.refreshPlatformStatus()

        #expect(platformStatusProvider.refreshCallCount == 1)
    }
}

private final class StubRunTrackingService: RunTrackingService {
    var latestSnapshot: RunTrackingSnapshot?
    var onSnapshot: ((RunTrackingSnapshot) -> Void)?

    private(set) var pauseCallCount = 0
    private(set) var resumeCallCount = 0

    init(snapshot: RunTrackingSnapshot) {
        latestSnapshot = snapshot
    }

    func start(settings: RunSettings, startedAt: Date) {
        if let latestSnapshot {
            onSnapshot?(latestSnapshot)
        }
    }

    func pause() {
        pauseCallCount += 1
    }

    func resume() {
        resumeCallCount += 1
    }

    func stop() {}
}

private final class StubRunPlatformStatusProvider: RunPlatformStatusProviding {
    var onStatusChange: ((RunPlatformStatus) -> Void)?

    private(set) var refreshCallCount = 0
    private var status: RunPlatformStatus

    init(
        status: RunPlatformStatus = RunPlatformStatus(
            trackingAuthorization: .authorized,
            trackingAvailability: .available,
            heartRateAvailability: .unavailable
        )
    ) {
        self.status = status
    }

    func currentPlatformStatus() -> RunPlatformStatus {
        status
    }

    func refreshPlatformStatus() {
        refreshCallCount += 1
        onStatusChange?(status)
    }

    func updateStatus(_ status: RunPlatformStatus) {
        self.status = status
        onStatusChange?(status)
    }
}

private struct StubRunSummaryBuilder: RunSummaryBuilding {
    func makeSummary(from session: ActiveRunSession, history: [RunSummary]) -> RunSummary {
        RunSummary(
            id: session.id,
            title: "Built Run",
            startedAt: Date(timeIntervalSince1970: 0),
            distanceMeters: 5_000,
            movingTimeSeconds: 1_500,
            elapsedTimeSeconds: 1_510,
            averagePaceSecondsPerSplit: 300,
            averageHeartRateBPM: 160,
            elevationGainMeters: 50,
            distanceUnit: .kilometers,
            splitUnit: .kilometer,
            routeShape: session.snapshot.routeShape,
            splits: [],
            heartRateZones: [],
            personalRecord: nil
        )
    }
}

private extension RunTrackingSnapshot {
    static let running = RunTrackingSnapshot(
        elapsedSeconds: 600,
        movingSeconds: 595,
        distanceMeters: 2_000,
        currentPaceSecondsPerSplit: 295,
        averagePaceSecondsPerSplit: 300,
        heartRate: 155,
        elevationGainMeters: 30,
        routeShape: [0.2, 0.3, 0.4]
    )

    static let finished = RunTrackingSnapshot(
        elapsedSeconds: 1_500,
        movingSeconds: 1_480,
        distanceMeters: 5_000,
        currentPaceSecondsPerSplit: 292,
        averagePaceSecondsPerSplit: 296,
        heartRate: 161,
        elevationGainMeters: 52,
        routeShape: [0.2, 0.3, 0.4, 0.5]
    )
}

private func makeTemporaryDirectory() -> URL {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
