//
//  TurnoverRunInterfaces.swift
//  Turnover
//
//  Created by Codex on 3/31/26.
//

import Foundation

enum PlatformAuthorizationState: Equatable {
    case notDetermined
    case authorized
    case denied
}

enum PlatformAvailabilityState: Equatable {
    case available
    case unavailable
}

struct RunPlatformStatus: Equatable {
    let trackingAuthorization: PlatformAuthorizationState
    let trackingAvailability: PlatformAvailabilityState
    let heartRateAvailability: PlatformAvailabilityState

    var canOpenSettings: Bool {
        trackingAuthorization == .denied
    }

    var liveStatusLabel: String {
        if trackingAvailability == .unavailable {
            return "Tracking unavailable"
        }

        switch trackingAuthorization {
        case .authorized:
            if heartRateAvailability == .available {
                return "GPS + HR ready"
            }

            return "GPS ready, HR unavailable"
        case .notDetermined:
            return "Permissions pending"
        case .denied:
            return "Location denied"
        }
    }
}

struct FinalizedRunPayload: Equatable {
    let session: ActiveRunSession
    let summary: RunSummary
}

protocol RunSettingsReading {
    func readSettings() -> SettingsSnapshot
}

protocol RunSettingsWriting {
    func writeSettings(_ settings: SettingsSnapshot)
}

protocol RunHistoryReading {
    func readRunHistory() -> [RunSummary]
}

protocol FinalizedRunWriting {
    func writeFinalizedRun(_ payload: FinalizedRunPayload)
}

protocol RunPlatformStatusProviding: AnyObject {
    var onStatusChange: ((RunPlatformStatus) -> Void)? { get set }

    func currentPlatformStatus() -> RunPlatformStatus
    func refreshPlatformStatus()
    func openSystemSettings()
}

struct TurnoverAppDependencies {
    let settingsReader: any RunSettingsReading
    let historyReader: any RunHistoryReading
    let finalizedRunWriter: any FinalizedRunWriting
    let trackingService: any RunTrackingService
    let platformStatusProvider: any RunPlatformStatusProviding

    static func local(fileManager: FileManager = .default) -> TurnoverAppDependencies {
        let settingsStore = LocalSettingsStore(fileManager: fileManager, baseDirectory: nil)
        let historyStore = LocalRunHistoryStore(fileManager: fileManager, baseDirectory: nil)
        let platformAdapter = CoreLocationRunTrackingService()

        return TurnoverAppDependencies(
            settingsReader: settingsStore,
            historyReader: historyStore,
            finalizedRunWriter: historyStore,
            trackingService: platformAdapter,
            platformStatusProvider: platformAdapter
        )
    }

    static func inMemory() -> TurnoverAppDependencies {
        let historyStore = InMemoryRunHistoryStore(seedRuns: TurnoverSampleData.recentRuns)
        let platformStatusProvider = MockRunPlatformStatusProvider()

        return TurnoverAppDependencies(
            settingsReader: InMemorySettingsStore(settings: TurnoverSampleData.settings),
            historyReader: historyStore,
            finalizedRunWriter: historyStore,
            trackingService: MockRunTrackingService(),
            platformStatusProvider: platformStatusProvider
        )
    }
}

struct InMemorySettingsStore: RunSettingsReading, RunSettingsWriting {
    let settings: SettingsSnapshot

    func readSettings() -> SettingsSnapshot {
        settings
    }

    func writeSettings(_ settings: SettingsSnapshot) {}
}

final class InMemoryRunHistoryStore: RunHistoryReading, FinalizedRunWriting {
    private let seedRuns: [RunSummary]
    private var writtenRuns: [FinalizedRunPayload] = []

    init(seedRuns: [RunSummary]) {
        self.seedRuns = seedRuns
    }

    func readRunHistory() -> [RunSummary] {
        writtenRuns.map(\.summary) + seedRuns
    }

    func writeFinalizedRun(_ payload: FinalizedRunPayload) {
        writtenRuns.insert(payload, at: 0)
    }
}

final class MockRunPlatformStatusProvider: RunPlatformStatusProviding {
    var onStatusChange: ((RunPlatformStatus) -> Void)?

    private let status: RunPlatformStatus

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
        onStatusChange?(status)
    }

    func openSystemSettings() {}
}
