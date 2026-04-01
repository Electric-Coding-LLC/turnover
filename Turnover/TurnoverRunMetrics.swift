//
//  TurnoverRunMetrics.swift
//  Turnover
//
//  Created by Codex on 3/31/26.
//

import Foundation

struct RunPersonalRecord: Identifiable, Equatable {
    let label: String
    let durationSeconds: Int
    let achievedOn: String

    var id: String { label }
}

struct RunHistoryMetrics: Equatable {
    let preferredDistanceUnit: DistanceUnit
    let weeklyDistanceMeters: Double
    let monthlyDistanceMeters: Double
    let latestRunDistanceMeters: Double?
    let runCount: Int
    let personalRecordCount: Int
    let personalRecords: [RunPersonalRecord]

    var weeklyDistanceSummary: String {
        formattedDistance(meters: weeklyDistanceMeters, maximumFractionDigits: 1)
    }

    var monthlyDistanceSummary: String {
        formattedDistance(meters: monthlyDistanceMeters, maximumFractionDigits: monthlyDistanceMeters >= 100_000 ? 0 : 1)
    }

    var latestRunDistanceSummary: String {
        guard let latestRunDistanceMeters else { return "--" }
        return formattedDistance(meters: latestRunDistanceMeters, maximumFractionDigits: 2)
    }

    var weeklyDistanceValue: String {
        formattedDistanceValue(meters: weeklyDistanceMeters, maximumFractionDigits: 1)
    }

    var monthlyDistanceValue: String {
        formattedDistanceValue(meters: monthlyDistanceMeters, maximumFractionDigits: monthlyDistanceMeters >= 100_000 ? 0 : 1)
    }

    var latestRunDistanceValue: String {
        guard let latestRunDistanceMeters else { return "--" }
        return formattedDistanceValue(meters: latestRunDistanceMeters, maximumFractionDigits: 2)
    }

    var distanceUnitLabel: String {
        preferredDistanceUnit.shortLabel
    }

    private func formattedDistance(meters: Double, maximumFractionDigits: Int) -> String {
        "\(formattedDistanceValue(meters: meters, maximumFractionDigits: maximumFractionDigits)) \(distanceUnitLabel)"
    }

    private func formattedDistanceValue(meters: Double, maximumFractionDigits: Int) -> String {
        let distance: Double

        switch preferredDistanceUnit {
        case .kilometers:
            distance = meters / 1_000.0
        case .miles:
            distance = meters / 1_609.34
        }

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumIntegerDigits = 1

        return formatter.string(from: NSNumber(value: distance)) ?? "0"
    }
}

protocol RunMetricsCalculating {
    func splitSummaries(for session: ActiveRunSession) -> [SplitSummary]
    func heartRateZones(from snapshot: RunTrackingSnapshot, settings: RunSettings) -> [HeartRateZoneSummary]
    func projectedPersonalRecord(for snapshot: RunTrackingSnapshot, settings: RunSettings, history: [RunSummary]) -> String?
    func summarizeHistory(_ history: [RunSummary], using settings: RunSettings, now: Date) -> RunHistoryMetrics
}

struct DefaultRunMetricsCalculator: RunMetricsCalculating {
    func splitSummaries(for session: ActiveRunSession) -> [SplitSummary] {
        let splitCount = max(1, Int(session.snapshot.distanceMeters / session.settings.splitUnit.distanceMeters))

        return (0..<splitCount).map { index in
            let paceDelta = Double(index) * 1.8
            let pace = max((session.snapshot.averagePaceSecondsPerSplit ?? 0) - paceDelta, 240)
            let heartRate = max((session.snapshot.heartRate ?? 150) + index * 2 - 2, 130)

            return SplitSummary(
                label: "\(index + 1) \(session.settings.splitUnit == .kilometer ? "km" : "mi")",
                pace: DefaultRunSummaryBuilder.compactDurationString(seconds: Int(pace.rounded())),
                heartRate: "\(heartRate)"
            )
        }
    }

    func heartRateZones(from snapshot: RunTrackingSnapshot, settings: RunSettings) -> [HeartRateZoneSummary] {
        let fractions = [0.12, 0.23, 0.34, 0.21, 0.10]

        return fractions.enumerated().map { index, fraction in
            HeartRateZoneSummary(
                label: "Z\(index + 1)",
                duration: DefaultRunSummaryBuilder.durationString(seconds: Int(Double(snapshot.movingSeconds) * fraction)),
                fraction: fraction
            )
        }
    }

    func projectedPersonalRecord(for snapshot: RunTrackingSnapshot, settings: RunSettings, history: [RunSummary]) -> String? {
        let projected5KSeconds = projectedTime(targetMeters: 5_000, snapshot: snapshot)
        guard let projected5KSeconds else { return nil }

        let historical5KBest = history
            .filter { $0.distanceMeters >= 5_000 }
            .map { run in
                Int((Double(run.movingTimeSeconds) / run.distanceMeters * 5_000).rounded())
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

    func summarizeHistory(_ history: [RunSummary], using settings: RunSettings, now: Date) -> RunHistoryMetrics {
        let calendar = Calendar.current
        let weeklyDistanceMeters = history
            .filter { calendar.isDate($0.startedAt, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.distanceMeters }
        let monthlyDistanceMeters = history
            .filter { calendar.isDate($0.startedAt, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.distanceMeters }
        let personalRecords = recordTargets.compactMap { target in
            bestRecord(for: target, history: history)
        }

        return RunHistoryMetrics(
            preferredDistanceUnit: settings.distanceUnit,
            weeklyDistanceMeters: weeklyDistanceMeters,
            monthlyDistanceMeters: monthlyDistanceMeters,
            latestRunDistanceMeters: history.first?.distanceMeters,
            runCount: history.count,
            personalRecordCount: history.filter { $0.personalRecord != nil }.count,
            personalRecords: personalRecords
        )
    }

    private var recordTargets: [(label: String, distanceMeters: Double)] {
        [
            ("Mile", 1_609.34),
            ("5K", 5_000)
        ]
    }

    private func bestRecord(for target: (label: String, distanceMeters: Double), history: [RunSummary]) -> RunPersonalRecord? {
        history
            .filter { $0.distanceMeters >= target.distanceMeters }
            .map { run in
                RunPersonalRecord(
                    label: target.label,
                    durationSeconds: Int((Double(run.movingTimeSeconds) / run.distanceMeters * target.distanceMeters).rounded()),
                    achievedOn: run.date
                )
            }
            .min { lhs, rhs in
                lhs.durationSeconds < rhs.durationSeconds
            }
    }

    private func projectedTime(targetMeters: Double, snapshot: RunTrackingSnapshot) -> Int? {
        guard snapshot.distanceMeters >= 1_000, snapshot.movingSeconds > 0 else { return nil }
        return Int((Double(snapshot.movingSeconds) / snapshot.distanceMeters * targetMeters).rounded())
    }
}
