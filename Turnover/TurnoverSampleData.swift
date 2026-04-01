//
//  TurnoverSampleData.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import Foundation

struct RunSummary: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: String
    let distance: String
    let movingTime: String
    let elapsedTime: String
    let averagePace: String
    let averageHeartRate: String
    let elevationGain: String
    let routeShape: [Double]
    let splits: [SplitSummary]
    let heartRateZones: [HeartRateZoneSummary]
    let personalRecord: String?
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
            title: "Morning Tempo",
            date: "Tue, Mar 31",
            distance: "8.42 km",
            movingTime: "43:20",
            elapsedTime: "45:12",
            averagePace: "5'08\" /km",
            averageHeartRate: "162 bpm",
            elevationGain: "124 m",
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
            title: "Easy Evening Run",
            date: "Sun, Mar 29",
            distance: "5.14 km",
            movingTime: "29:58",
            elapsedTime: "31:10",
            averagePace: "5'50\" /km",
            averageHeartRate: "148 bpm",
            elevationGain: "42 m",
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
            title: "Long Saturday Run",
            date: "Sat, Mar 28",
            distance: "16.80 km",
            movingTime: "1:31:42",
            elapsedTime: "1:34:05",
            averagePace: "5'27\" /km",
            averageHeartRate: "156 bpm",
            elevationGain: "210 m",
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
        distanceUnit: .kilometers,
        splitUnit: .kilometer,
        autoPauseEnabled: true,
        zoneMethod: .percentOfMaxHeartRate,
        maxHeartRate: 190,
        version: "0.1.0"
    )
}

struct SettingsSnapshot {
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
}
