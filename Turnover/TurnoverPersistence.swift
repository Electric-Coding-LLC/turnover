//
//  TurnoverPersistence.swift
//  Turnover
//
//  Created by Codex on 4/1/26.
//

import Foundation

struct LocalSettingsStore: RunSettingsReading, RunSettingsWriting {
    private let storage: JSONFileStorage<PersistedSettingsRecord>

    init(fileManager: FileManager = .default, baseDirectory: URL? = nil) {
        storage = JSONFileStorage(
            fileManager: fileManager,
            baseDirectory: baseDirectory,
            filename: "settings.json",
            seedValue: PersistedSettingsRecord(TurnoverSampleData.settings)
        )
    }

    func readSettings() -> SettingsSnapshot {
        storage.read().settingsSnapshot
    }

    func writeSettings(_ settings: SettingsSnapshot) {
        storage.write(PersistedSettingsRecord(settings))
    }
}

final class LocalRunHistoryStore: RunHistoryReading, FinalizedRunWriting {
    private let storage: JSONFileStorage<[PersistedRunSummaryRecord]>

    init(fileManager: FileManager = .default, baseDirectory: URL? = nil) {
        storage = JSONFileStorage(
            fileManager: fileManager,
            baseDirectory: baseDirectory,
            filename: "run-history.json",
            seedValue: TurnoverSampleData.recentRuns.map(PersistedRunSummaryRecord.init)
        )
    }

    func readRunHistory() -> [RunSummary] {
        storage.read().map(\.runSummary)
    }

    func writeFinalizedRun(_ payload: FinalizedRunPayload) {
        var runs = storage.read()
        runs.insert(PersistedRunSummaryRecord(payload.summary), at: 0)
        storage.write(runs)
    }
}

private struct JSONFileStorage<Value: Codable> {
    private let fileManager: FileManager
    private let fileURL: URL
    private let seedValue: Value
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager, baseDirectory: URL?, filename: String, seedValue: Value) {
        self.fileManager = fileManager
        self.seedValue = seedValue

        let baseDirectory = baseDirectory ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let appDirectory = baseDirectory.appendingPathComponent("Turnover", isDirectory: true)
        self.fileURL = appDirectory.appendingPathComponent(filename)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = encoder

        let decoder = JSONDecoder()
        self.decoder = decoder
    }

    func read() -> Value {
        ensureSeedFileExists()

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(Value.self, from: data)
        } catch {
            write(seedValue)
            return seedValue
        }
    }

    func write(_ value: Value) {
        do {
            try createDirectoryIfNeeded()
            let data = try encoder.encode(value)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            assertionFailure("Failed to write persistence file at \(fileURL.path): \(error)")
        }
    }

    private func ensureSeedFileExists() {
        guard !fileManager.fileExists(atPath: fileURL.path) else { return }
        write(seedValue)
    }

    private func createDirectoryIfNeeded() throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}

private struct PersistedSettingsRecord: Codable {
    let distanceUnit: String
    let splitUnit: String
    let autoPauseEnabled: Bool
    let zoneMethod: String
    let maxHeartRate: Int
    let version: String

    init(_ settings: SettingsSnapshot) {
        distanceUnit = settings.distanceUnit.rawValue
        splitUnit = settings.splitUnit.persistenceKey
        autoPauseEnabled = settings.autoPauseEnabled
        zoneMethod = settings.zoneMethod.persistenceKey
        maxHeartRate = settings.maxHeartRate
        version = settings.version
    }

    var settingsSnapshot: SettingsSnapshot {
        SettingsSnapshot(
            distanceUnit: DistanceUnit(rawValue: distanceUnit) ?? TurnoverSampleData.settings.distanceUnit,
            splitUnit: SplitUnit(persistenceKey: splitUnit) ?? TurnoverSampleData.settings.splitUnit,
            autoPauseEnabled: autoPauseEnabled,
            zoneMethod: HeartRateZoneMethod(persistenceKey: zoneMethod) ?? TurnoverSampleData.settings.zoneMethod,
            maxHeartRate: maxHeartRate,
            version: version
        )
    }
}

private struct PersistedRunSummaryRecord: Codable {
    let id: UUID
    let title: String
    let startedAt: Date
    let distanceMeters: Double
    let movingTimeSeconds: Int
    let elapsedTimeSeconds: Int
    let averagePaceSecondsPerSplit: Double?
    let averageHeartRateBPM: Int?
    let elevationGainMeters: Double
    let distanceUnit: String
    let splitUnit: String
    let routeShape: [Double]
    let splits: [PersistedSplitSummaryRecord]
    let heartRateZones: [PersistedHeartRateZoneRecord]
    let personalRecord: String?

    init(_ summary: RunSummary) {
        id = summary.id
        title = summary.title
        startedAt = summary.startedAt
        distanceMeters = summary.distanceMeters
        movingTimeSeconds = summary.movingTimeSeconds
        elapsedTimeSeconds = summary.elapsedTimeSeconds
        averagePaceSecondsPerSplit = summary.averagePaceSecondsPerSplit
        averageHeartRateBPM = summary.averageHeartRateBPM
        elevationGainMeters = summary.elevationGainMeters
        distanceUnit = summary.distanceUnit.rawValue
        splitUnit = summary.splitUnit.persistenceKey
        routeShape = summary.routeShape
        splits = summary.splits.map(PersistedSplitSummaryRecord.init)
        heartRateZones = summary.heartRateZones.map(PersistedHeartRateZoneRecord.init)
        personalRecord = summary.personalRecord
    }

    var runSummary: RunSummary {
        RunSummary(
            id: id,
            title: title,
            startedAt: startedAt,
            distanceMeters: distanceMeters,
            movingTimeSeconds: movingTimeSeconds,
            elapsedTimeSeconds: elapsedTimeSeconds,
            averagePaceSecondsPerSplit: averagePaceSecondsPerSplit,
            averageHeartRateBPM: averageHeartRateBPM,
            elevationGainMeters: elevationGainMeters,
            distanceUnit: DistanceUnit(rawValue: distanceUnit) ?? TurnoverSampleData.settings.distanceUnit,
            splitUnit: SplitUnit(persistenceKey: splitUnit) ?? TurnoverSampleData.settings.splitUnit,
            routeShape: routeShape,
            splits: splits.map(\.splitSummary),
            heartRateZones: heartRateZones.map(\.heartRateZone),
            personalRecord: personalRecord
        )
    }
}

private struct PersistedSplitSummaryRecord: Codable {
    let label: String
    let pace: String
    let heartRate: String

    init(_ split: SplitSummary) {
        label = split.label
        pace = split.pace
        heartRate = split.heartRate
    }

    var splitSummary: SplitSummary {
        SplitSummary(label: label, pace: pace, heartRate: heartRate)
    }
}

private struct PersistedHeartRateZoneRecord: Codable {
    let label: String
    let duration: String
    let fraction: Double

    init(_ zone: HeartRateZoneSummary) {
        label = zone.label
        duration = zone.duration
        fraction = zone.fraction
    }

    var heartRateZone: HeartRateZoneSummary {
        HeartRateZoneSummary(label: label, duration: duration, fraction: fraction)
    }
}

private extension SplitUnit {
    var persistenceKey: String {
        switch self {
        case .kilometer:
            return "kilometer"
        case .mile:
            return "mile"
        }
    }

    init?(persistenceKey: String) {
        switch persistenceKey {
        case "kilometer":
            self = .kilometer
        case "mile":
            self = .mile
        default:
            return nil
        }
    }
}

private extension HeartRateZoneMethod {
    var persistenceKey: String {
        switch self {
        case .percentOfMaxHeartRate:
            return "percentOfMaxHeartRate"
        }
    }

    init?(persistenceKey: String) {
        switch persistenceKey {
        case "percentOfMaxHeartRate":
            self = .percentOfMaxHeartRate
        default:
            return nil
        }
    }
}
