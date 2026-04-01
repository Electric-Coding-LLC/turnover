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

    var liveStatusLabel: String {
        if trackingAvailability == .unavailable {
            return "Tracking unavailable"
        }

        switch trackingAuthorization {
        case .authorized:
            return "GPS ready"
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

protocol RunHistoryReading {
    func readRunHistory() -> [RunSummary]
}

protocol FinalizedRunWriting {
    func writeFinalizedRun(_ payload: FinalizedRunPayload)
}

protocol RunPlatformStatusProviding {
    func currentPlatformStatus() -> RunPlatformStatus
}

struct TurnoverAppDependencies {
    let settingsReader: any RunSettingsReading
    let historyReader: any RunHistoryReading
    let finalizedRunWriter: any FinalizedRunWriting
    let platformStatusProvider: any RunPlatformStatusProviding

    static func inMemory() -> TurnoverAppDependencies {
        let historyStore = InMemoryRunHistoryStore(seedRuns: TurnoverSampleData.recentRuns)

        return TurnoverAppDependencies(
            settingsReader: InMemorySettingsStore(settings: TurnoverSampleData.settings),
            historyReader: historyStore,
            finalizedRunWriter: historyStore,
            platformStatusProvider: MockRunPlatformStatusProvider()
        )
    }
}

struct InMemorySettingsStore: RunSettingsReading {
    let settings: SettingsSnapshot

    func readSettings() -> SettingsSnapshot {
        settings
    }
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

struct MockRunPlatformStatusProvider: RunPlatformStatusProviding {
    func currentPlatformStatus() -> RunPlatformStatus {
        RunPlatformStatus(
            trackingAuthorization: .authorized,
            trackingAvailability: .available,
            heartRateAvailability: .available
        )
    }
}
