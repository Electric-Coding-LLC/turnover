//
//  TurnoverRunDomain.swift
//  Turnover
//
//  Created by Codex on 3/31/26.
//

import Foundation

enum DistanceUnit: String, Hashable {
    case kilometers
    case miles

    var label: String {
        switch self {
        case .kilometers:
            "Kilometers"
        case .miles:
            "Miles"
        }
    }

    var shortLabel: String {
        switch self {
        case .kilometers:
            "km"
        case .miles:
            "mi"
        }
    }
}

enum SplitUnit: Hashable {
    case kilometer
    case mile

    var label: String {
        switch self {
        case .kilometer:
            "1 km"
        case .mile:
            "1 mi"
        }
    }

    var shortLabel: String {
        switch self {
        case .kilometer:
            "/km"
        case .mile:
            "/mi"
        }
    }

    var distanceMeters: Double {
        switch self {
        case .kilometer:
            1_000
        case .mile:
            1_609.34
        }
    }
}

enum HeartRateZoneMethod: Hashable {
    case percentOfMaxHeartRate

    var label: String {
        switch self {
        case .percentOfMaxHeartRate:
            "Percent of Max HR"
        }
    }
}

struct RunSettings: Hashable {
    let distanceUnit: DistanceUnit
    let splitUnit: SplitUnit
    let autoPauseEnabled: Bool
    let zoneMethod: HeartRateZoneMethod
    let maxHeartRate: Int
}

struct RunTrackingSnapshot: Equatable {
    let elapsedSeconds: Int
    let movingSeconds: Int
    let distanceMeters: Double
    let currentPaceSecondsPerSplit: Double?
    let averagePaceSecondsPerSplit: Double?
    let heartRate: Int?
    let elevationGainMeters: Double
    let routeShape: [Double]
}

struct ActiveRunSession: Equatable {
    let id: UUID
    let startedAt: Date
    let settings: RunSettings
    let snapshot: RunTrackingSnapshot
}

enum RunSessionState: Equatable {
    case idle
    case active(ActiveRunSession)
    case paused(ActiveRunSession)
    case completed(RunSummary)
}

protocol RunTrackingService: AnyObject {
    var latestSnapshot: RunTrackingSnapshot? { get }
    var onSnapshot: ((RunTrackingSnapshot) -> Void)? { get set }

    func start(settings: RunSettings, startedAt: Date)
    func pause()
    func resume()
    func stop()
}

protocol RunSummaryBuilding {
    func makeSummary(from session: ActiveRunSession, history: [RunSummary]) -> RunSummary
}

final class MockRunTrackingService: RunTrackingService {
    var onSnapshot: ((RunTrackingSnapshot) -> Void)?
    private(set) var latestSnapshot: RunTrackingSnapshot?

    private let sampleRoute = TurnoverSampleData.featuredRun.routeShape
    private var timer: Timer?
    private var secondsTicked = 0
    private var startedAt: Date?
    private var settings: RunSettings?

    func start(settings: RunSettings, startedAt: Date) {
        stop()

        self.settings = settings
        self.startedAt = startedAt
        secondsTicked = 0

        let initialSnapshot = makeSnapshot()
        latestSnapshot = initialSnapshot
        onSnapshot?(initialSnapshot)
        startTimer()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard timer == nil, startedAt != nil, settings != nil else { return }
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            secondsTicked += 1
            let snapshot = makeSnapshot()
            latestSnapshot = snapshot
            onSnapshot?(snapshot)
        }
    }

    private func makeSnapshot() -> RunTrackingSnapshot {
        let activeSeconds = max(secondsTicked, 1)
        let progress = Double(activeSeconds)
        let basePaceSecondsPerKilometer = 305.0 + sin(progress / 12.0) * 9.0
        let metersPerSecond = 1_000.0 / basePaceSecondsPerKilometer
        let distanceMeters = Double(activeSeconds) * metersPerSecond
        let heartRate = Int(148.0 + sin(progress / 8.0) * 12.0 + min(progress / 18.0, 12.0))
        let elevationGainMeters = distanceMeters * 0.012
        let routePrefixCount = max(2, min(sampleRoute.count, Int(progress / 8.0) + 2))
        let routeShape = Array(sampleRoute.prefix(routePrefixCount))

        return RunTrackingSnapshot(
            elapsedSeconds: activeSeconds,
            movingSeconds: activeSeconds,
            distanceMeters: distanceMeters,
            currentPaceSecondsPerSplit: paceForSettings(basePaceSecondsPerKilometer),
            averagePaceSecondsPerSplit: paceForSettings(1_000.0 * Double(activeSeconds) / max(distanceMeters, 1)),
            heartRate: heartRate,
            elevationGainMeters: elevationGainMeters,
            routeShape: routeShape
        )
    }

    private func paceForSettings(_ paceSecondsPerKilometer: Double) -> Double {
        guard let settings else { return paceSecondsPerKilometer }

        switch settings.splitUnit {
        case .kilometer:
            return paceSecondsPerKilometer
        case .mile:
            return paceSecondsPerKilometer * 1.60934
        }
    }
}

struct DefaultRunSummaryBuilder: RunSummaryBuilding {
    func makeSummary(from session: ActiveRunSession, history: [RunSummary]) -> RunSummary {
        let snapshot = session.snapshot
        let splitCount = max(1, Int(snapshot.distanceMeters / session.settings.splitUnit.distanceMeters))
        let splits = buildSplits(for: session, count: splitCount)
        let heartRateZones = buildHeartRateZones(from: snapshot)
        let personalRecord = projectedPersonalRecord(for: snapshot, settings: session.settings, history: history)

        return RunSummary(
            title: generatedTitle(for: snapshot.distanceMeters),
            date: Self.dateFormatter.string(from: session.startedAt),
            distance: Self.distanceString(meters: snapshot.distanceMeters, unit: session.settings.distanceUnit),
            movingTime: Self.durationString(seconds: snapshot.movingSeconds),
            elapsedTime: Self.durationString(seconds: snapshot.elapsedSeconds),
            averagePace: Self.paceString(secondsPerSplit: snapshot.averagePaceSecondsPerSplit, splitUnit: session.settings.splitUnit),
            averageHeartRate: snapshot.heartRate.map { "\($0) bpm" } ?? "N/A",
            elevationGain: "\(Int(snapshot.elevationGainMeters.rounded())) m",
            routeShape: snapshot.routeShape,
            splits: splits,
            heartRateZones: heartRateZones,
            personalRecord: personalRecord
        )
    }

    private func buildSplits(for session: ActiveRunSession, count: Int) -> [SplitSummary] {
        (0..<count).map { index in
            let paceDelta = Double(index) * 1.8
            let pace = max((session.snapshot.averagePaceSecondsPerSplit ?? 0) - paceDelta, 240)
            let heartRate = max((session.snapshot.heartRate ?? 150) + index * 2 - 2, 130)

            return SplitSummary(
                label: "\(index + 1) \(session.settings.splitUnit == .kilometer ? "km" : "mi")",
                pace: Self.compactDurationString(seconds: Int(pace.rounded())),
                heartRate: "\(heartRate)"
            )
        }
    }

    private func buildHeartRateZones(from snapshot: RunTrackingSnapshot) -> [HeartRateZoneSummary] {
        let fractions = [0.12, 0.23, 0.34, 0.21, 0.10]

        return fractions.enumerated().map { index, fraction in
            HeartRateZoneSummary(
                label: "Z\(index + 1)",
                duration: Self.durationString(seconds: Int(Double(snapshot.movingSeconds) * fraction)),
                fraction: fraction
            )
        }
    }

    private func projectedPersonalRecord(for snapshot: RunTrackingSnapshot, settings: RunSettings, history: [RunSummary]) -> String? {
        let projected5KSeconds = projectedTime(targetMeters: 5_000, snapshot: snapshot)
        guard let projected5KSeconds else { return nil }

        let historical5KBest = history
            .filter { $0.distance.hasSuffix("km") }
            .compactMap { run -> Int? in
                guard let distance = Self.parseDistanceKilometers(from: run.distance),
                      distance >= 5.0 else {
                    return nil
                }

                return Self.parseDuration(from: run.movingTime).map { Int(Double($0) * (5.0 / distance)) }
            }
            .min()

        guard let historical5KBest else { return "New 5K best projection" }

        if projected5KSeconds < historical5KBest {
            return "New 5K best projection"
        }

        if settings.autoPauseEnabled, snapshot.distanceMeters >= 3_000 {
            return "Strong negative split trend"
        }

        return nil
    }

    private func projectedTime(targetMeters: Double, snapshot: RunTrackingSnapshot) -> Int? {
        guard snapshot.distanceMeters >= 1_000, snapshot.movingSeconds > 0 else { return nil }
        return Int((Double(snapshot.movingSeconds) / snapshot.distanceMeters * targetMeters).rounded())
    }

    private func generatedTitle(for distanceMeters: Double) -> String {
        if distanceMeters >= 10_000 {
            return "Long Progression Run"
        }

        if distanceMeters >= 5_000 {
            return "Steady Tempo Run"
        }

        return "Quick Shakeout"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()

    static func distanceString(meters: Double, unit: DistanceUnit) -> String {
        switch unit {
        case .kilometers:
            String(format: "%.2f km", meters / 1_000.0)
        case .miles:
            String(format: "%.2f mi", meters / 1_609.34)
        }
    }

    static func paceString(secondsPerSplit: Double?, splitUnit: SplitUnit) -> String {
        guard let secondsPerSplit else { return "N/A" }
        return "\(compactDurationString(seconds: Int(secondsPerSplit.rounded()))) \(splitUnit.shortLabel)"
    }

    static func durationString(seconds: Int) -> String {
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        }

        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    static func compactDurationString(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)'\(String(format: "%02d", remainingSeconds))\""
    }

    private static func parseDuration(from value: String) -> Int? {
        let parts = value.split(separator: ":").compactMap { Int($0) }

        switch parts.count {
        case 2:
            return parts[0] * 60 + parts[1]
        case 3:
            return parts[0] * 3_600 + parts[1] * 60 + parts[2]
        default:
            return nil
        }
    }

    private static func parseDistanceKilometers(from value: String) -> Double? {
        guard let number = Double(value.split(separator: " ").first ?? "") else { return nil }
        return value.hasSuffix("km") ? number : nil
    }
}
