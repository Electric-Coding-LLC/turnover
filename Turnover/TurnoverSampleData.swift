//
//  TurnoverSampleData.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import Foundation

struct RunSummary: Identifiable, Hashable {
    let id: UUID
    let title: String
    let startedAt: Date
    let distanceMeters: Double
    let movingTimeSeconds: Int
    let elapsedTimeSeconds: Int
    let averagePaceSecondsPerSplit: Double?
    let averageHeartRateBPM: Int?
    let elevationGainMeters: Double
    let distanceUnit: DistanceUnit
    let splitUnit: SplitUnit
    let routeShape: [Double]
    let splits: [SplitSummary]
    let heartRateZones: [HeartRateZoneSummary]
    let personalRecord: String?

    var date: String {
        DefaultRunSummaryBuilder.dateString(from: startedAt)
    }

    var distance: String {
        DefaultRunSummaryBuilder.distanceString(meters: distanceMeters, unit: distanceUnit)
    }

    var movingTime: String {
        DefaultRunSummaryBuilder.durationString(seconds: movingTimeSeconds)
    }

    var elapsedTime: String {
        DefaultRunSummaryBuilder.durationString(seconds: elapsedTimeSeconds)
    }

    var averagePace: String {
        DefaultRunSummaryBuilder.paceString(
            secondsPerSplit: averagePaceSecondsPerSplit,
            splitUnit: splitUnit
        )
    }

    var averageHeartRate: String {
        averageHeartRateBPM.map { "\($0) bpm" } ?? "N/A"
    }

    var elevationGain: String {
        "\(Int(elevationGainMeters.rounded())) m"
    }
}

struct SplitSummary: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let pace: String
    let heartRate: String
}

struct HeartRateZoneSummary: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let duration: String
    let fraction: Double
}

enum TurnoverSampleData {
    static let recentRuns: [RunSummary] = [
        RunSummary(
            id: UUID(),
            title: "Morning Tempo",
            startedAt: sampleDate(year: 2026, month: 3, day: 31),
            distanceMeters: 8_420,
            movingTimeSeconds: 2_600,
            elapsedTimeSeconds: 2_712,
            averagePaceSecondsPerSplit: 308,
            averageHeartRateBPM: 162,
            elevationGainMeters: 124,
            distanceUnit: .kilometers,
            splitUnit: .kilometer,
            routeShape: [0.25, 0.41, 0.55, 0.38, 0.63, 0.49, 0.72, 0.60, 0.78],
            splits: [
                SplitSummary(label: "1 km", pace: "5'12\"", heartRate: "154"),
                SplitSummary(label: "2 km", pace: "5'07\"", heartRate: "159"),
                SplitSummary(label: "3 km", pace: "5'05\"", heartRate: "162"),
                SplitSummary(label: "4 km", pace: "5'02\"", heartRate: "165"),
                SplitSummary(label: "5 km", pace: "4'58\"", heartRate: "168")
            ],
            heartRateZones: [
                HeartRateZoneSummary(label: "Z1", duration: "03:10", fraction: 0.12),
                HeartRateZoneSummary(label: "Z2", duration: "09:30", fraction: 0.24),
                HeartRateZoneSummary(label: "Z3", duration: "17:40", fraction: 0.39),
                HeartRateZoneSummary(label: "Z4", duration: "10:50", fraction: 0.20),
                HeartRateZoneSummary(label: "Z5", duration: "02:10", fraction: 0.05)
            ],
            personalRecord: "New 10K best projection"
        ),
        RunSummary(
            id: UUID(),
            title: "Easy Evening Run",
            startedAt: sampleDate(year: 2026, month: 3, day: 29),
            distanceMeters: 5_140,
            movingTimeSeconds: 1_798,
            elapsedTimeSeconds: 1_870,
            averagePaceSecondsPerSplit: 350,
            averageHeartRateBPM: 148,
            elevationGainMeters: 42,
            distanceUnit: .kilometers,
            splitUnit: .kilometer,
            routeShape: [0.20, 0.30, 0.44, 0.51, 0.46, 0.56, 0.61, 0.58, 0.66],
            splits: [
                SplitSummary(label: "1 km", pace: "5'55\"", heartRate: "141"),
                SplitSummary(label: "2 km", pace: "5'48\"", heartRate: "145"),
                SplitSummary(label: "3 km", pace: "5'47\"", heartRate: "148")
            ],
            heartRateZones: [
                HeartRateZoneSummary(label: "Z1", duration: "07:20", fraction: 0.25),
                HeartRateZoneSummary(label: "Z2", duration: "13:30", fraction: 0.45),
                HeartRateZoneSummary(label: "Z3", duration: "07:40", fraction: 0.26),
                HeartRateZoneSummary(label: "Z4", duration: "01:28", fraction: 0.04)
            ],
            personalRecord: nil
        ),
        RunSummary(
            id: UUID(),
            title: "Long Saturday Run",
            startedAt: sampleDate(year: 2026, month: 3, day: 28),
            distanceMeters: 16_800,
            movingTimeSeconds: 5_502,
            elapsedTimeSeconds: 5_645,
            averagePaceSecondsPerSplit: 327,
            averageHeartRateBPM: 156,
            elevationGainMeters: 210,
            distanceUnit: .kilometers,
            splitUnit: .kilometer,
            routeShape: [0.18, 0.28, 0.35, 0.48, 0.53, 0.57, 0.68, 0.74, 0.82],
            splits: [
                SplitSummary(label: "1 km", pace: "5'35\"", heartRate: "144"),
                SplitSummary(label: "2 km", pace: "5'29\"", heartRate: "149"),
                SplitSummary(label: "3 km", pace: "5'24\"", heartRate: "151")
            ],
            heartRateZones: [
                HeartRateZoneSummary(label: "Z1", duration: "11:40", fraction: 0.12),
                HeartRateZoneSummary(label: "Z2", duration: "38:10", fraction: 0.42),
                HeartRateZoneSummary(label: "Z3", duration: "30:40", fraction: 0.33),
                HeartRateZoneSummary(label: "Z4", duration: "11:12", fraction: 0.13)
            ],
            personalRecord: "New half marathon PR"
        )
    ]

    static let featuredRun = recentRuns[0]

    static let settings = SettingsSnapshot(
        distanceUnit: .miles,
        splitUnit: .mile,
        autoPauseEnabled: true,
        zoneMethod: .percentOfMaxHeartRate,
        maxHeartRate: 190,
        version: "0.1.0"
    )

    private static func sampleDate(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}

struct SettingsSnapshot: Equatable {
    let distanceUnit: DistanceUnit
    let splitUnit: SplitUnit
    let autoPauseEnabled: Bool
    let zoneMethod: HeartRateZoneMethod
    let maxHeartRate: Int
    let version: String

    var distanceUnitLabel: String { distanceUnit.label }
    var splitUnitLabel: String { splitUnit.label }
    var zoneMethodLabel: String { zoneMethod.label }
    var maxHeartRateLabel: String { "\(maxHeartRate) bpm" }

    var runSettings: RunSettings {
        RunSettings(
            distanceUnit: distanceUnit,
            splitUnit: splitUnit,
            autoPauseEnabled: autoPauseEnabled,
            zoneMethod: zoneMethod,
            maxHeartRate: maxHeartRate
        )
    }

    func updating(
        distanceUnit: DistanceUnit? = nil,
        splitUnit: SplitUnit? = nil,
        autoPauseEnabled: Bool? = nil,
        zoneMethod: HeartRateZoneMethod? = nil,
        maxHeartRate: Int? = nil
    ) -> SettingsSnapshot {
        SettingsSnapshot(
            distanceUnit: distanceUnit ?? self.distanceUnit,
            splitUnit: splitUnit ?? self.splitUnit,
            autoPauseEnabled: autoPauseEnabled ?? self.autoPauseEnabled,
            zoneMethod: zoneMethod ?? self.zoneMethod,
            maxHeartRate: maxHeartRate ?? self.maxHeartRate,
            version: version
        )
    }
}
