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
    private let metricsCalculator: any RunMetricsCalculating

    init(metricsCalculator: any RunMetricsCalculating = DefaultRunMetricsCalculator()) {
        self.metricsCalculator = metricsCalculator
    }

    func makeSummary(from session: ActiveRunSession, history: [RunSummary]) -> RunSummary {
        let snapshot = session.snapshot
        let splits = metricsCalculator.splitSummaries(for: session)
        let heartRateZones = metricsCalculator.heartRateZones(from: snapshot, settings: session.settings)
        let personalRecord = metricsCalculator.projectedPersonalRecord(
            for: snapshot,
            settings: session.settings,
            history: history
        )

        return RunSummary(
            id: session.id,
            title: generatedTitle(for: snapshot.distanceMeters),
            startedAt: session.startedAt,
            distanceMeters: snapshot.distanceMeters,
            movingTimeSeconds: snapshot.movingSeconds,
            elapsedTimeSeconds: snapshot.elapsedSeconds,
            averagePaceSecondsPerSplit: snapshot.averagePaceSecondsPerSplit,
            averageHeartRateBPM: snapshot.heartRate,
            elevationGainMeters: snapshot.elevationGainMeters,
            distanceUnit: session.settings.distanceUnit,
            splitUnit: session.settings.splitUnit,
            routeShape: snapshot.routeShape,
            splits: splits,
            heartRateZones: heartRateZones,
            personalRecord: personalRecord
        )
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

    private static let longDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()

    private static let mediumDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func longDateString(from date: Date) -> String {
        longDateFormatter.string(from: date)
    }

    static func mediumDateString(from date: Date) -> String {
        mediumDateFormatter.string(from: date)
    }

    static func shortDateString(from date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

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
}
