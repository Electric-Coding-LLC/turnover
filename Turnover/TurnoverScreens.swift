//
//  TurnoverScreens.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

struct HomeScreen: View {
    let onStartRun: () -> Void
    private let featuredRun = TurnoverSampleData.featuredRun

    var body: some View {
        TurnoverScreen(title: "Turnover") {
            HeroSectionCard(
                eyebrow: "Ready",
                title: "Track the work. Skip the feed.",
                subtitle: "Fast access to live tracking, recent volume, and the run data that matters."
            ) {
                Button("Start Run", action: onStartRun)
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityIdentifier("start-run-button")

                HStack(spacing: 12) {
                    MetricColumn(label: "Week", value: "30.4 km")
                    MetricColumn(label: "Month", value: "112 km")
                    MetricColumn(label: "Latest", value: "8.42 km")
                }
            }

            SectionCard(title: "This Week", trailing: "7 days") {
                HStack(spacing: 12) {
                    MetricTile(label: "Mileage", value: "30.4", detail: "km logged", emphasis: .subdued)
                    MetricTile(label: "Month", value: "112", detail: "km total", emphasis: .subdued)
                }

                HStack(spacing: 12) {
                    MetricTile(label: "Latest", value: "8.42", detail: "km tempo", accent: TurnoverPalette.success, emphasis: .subdued)
                    MetricTile(label: "PRs", value: "2", detail: "updated", accent: TurnoverPalette.warning, emphasis: .subdued)
                }
            }

            NavigationLink(value: featuredRun) {
                SectionCard(title: "Latest Run", trailing: featuredRun.date) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(featuredRun.title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(TurnoverPalette.textPrimary)

                        RoutePreview(shape: featuredRun.routeShape)
                            .frame(height: 88)

                        HStack(spacing: 12) {
                            MetricColumn(label: "Distance", value: featuredRun.distance)
                            MetricColumn(label: "Pace", value: featuredRun.averagePace)
                            MetricColumn(label: "Time", value: featuredRun.movingTime)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            SectionCard(title: "Personal Records", trailing: "V1") {
                VStack(spacing: 12) {
                    RecordRow(label: "Mile", value: "6:01", detail: "Mar 21")
                    RecordRow(label: "5K", value: "21:12", detail: "Mar 12")
                }
            }
        }
    }
}

struct LiveRunScreen: View {
    let sessionPhase: RunSessionPhase
    let latestCompletedRun: RunSummary?
    let onStartRun: () -> Void
    let onPauseRun: () -> Void
    let onResumeRun: () -> Void
    let onFinishRun: () -> Void
    let onViewLatestRun: () -> Void

    var body: some View {
        TurnoverScreen(title: "Live Run") {
            switch sessionPhase {
            case .idle:
                idleRunContent
            case .active, .paused:
                activeRunContent
            case .completed:
                completedRunContent
            }
        }
    }

    private var idleRunContent: some View {
        HeroSectionCard(
            eyebrow: "Ready",
            title: "Start a session from here or jump in from Home.",
            subtitle: "Step 7 wires the run flow so the tab, session state, and summary route all behave like one app."
        ) {
            Button("Start Run", action: onStartRun)
                .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var activeRunContent: some View {
        Group {
            SectionCard(title: sessionPhase == .paused ? "Paused" : "Active Run", trailing: "GPS strong") {
                VStack(alignment: .leading, spacing: 18) {
                    Text("00:43:20")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(TurnoverPalette.textPrimary)
                        .monospacedDigit()

                    Text("Elapsed time")
                        .font(.subheadline)
                        .foregroundStyle(TurnoverPalette.textSecondary)

                    Capsule()
                        .fill(TurnoverPalette.surfaceRaised)
                        .frame(height: 1)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    MetricTile(label: "Distance", value: "8.42", detail: "km")
                    MetricTile(label: "Current Pace", value: "4'58", detail: "/km")
                    MetricTile(label: "Avg Pace", value: "5'08", detail: "/km")
                    MetricTile(label: "Heart Rate", value: "162", detail: "bpm", accent: TurnoverPalette.warning)
                }
            }

            SectionCard(title: "Route", trailing: "Secondary") {
                RoutePreview(shape: TurnoverSampleData.featuredRun.routeShape)
                    .frame(height: 120)
            }

            SectionCard(title: "Controls") {
                if sessionPhase == .paused {
                    HStack(spacing: 12) {
                        Button("Resume", action: onResumeRun)
                            .buttonStyle(PrimaryButtonStyle())

                        Button("Finish", action: onFinishRun)
                            .buttonStyle(SecondaryButtonStyle())
                    }
                } else {
                    HStack(spacing: 12) {
                        Button("Pause", action: onPauseRun)
                            .buttonStyle(PrimaryButtonStyle())

                        Button("Finish", action: onFinishRun)
                            .buttonStyle(SecondaryButtonStyle())
                    }
                }
            }
        }
    }

    private var completedRunContent: some View {
        Group {
            HeroSectionCard(
                eyebrow: "Complete",
                title: "Run finished. Summary is ready.",
                subtitle: "The live tab now owns the handoff from an active session into a saved run summary."
            ) {
                HStack(spacing: 12) {
                    Button("View Summary", action: onViewLatestRun)
                        .buttonStyle(PrimaryButtonStyle())

                    Button("Start Another", action: onStartRun)
                        .buttonStyle(SecondaryButtonStyle())
                }
            }

            if let latestCompletedRun {
                SectionCard(title: "Latest Completed Run", trailing: latestCompletedRun.date) {
                    HStack(spacing: 12) {
                        MetricColumn(label: "Distance", value: latestCompletedRun.distance)
                        MetricColumn(label: "Pace", value: latestCompletedRun.averagePace)
                        MetricColumn(label: "Moving", value: latestCompletedRun.movingTime)
                    }
                }
            }
        }
    }
}

struct HistoryScreen: View {
    private let runs = TurnoverSampleData.recentRuns

    var body: some View {
        TurnoverScreen(title: "History") {
            SectionCard(title: "Summary", trailing: "Recent") {
                HStack(spacing: 12) {
                    MetricTile(label: "Runs", value: "\(runs.count)", detail: "sample sessions")
                    MetricTile(label: "Mileage", value: "30.4", detail: "km this week")
                }
            }

            SectionCard(title: "Completed Runs", trailing: "No extras") {
                VStack(spacing: 14) {
                    ForEach(runs) { run in
                        NavigationLink(value: run) {
                            RunHistoryRow(run: run)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct RunDetailScreen: View {
    let run: RunSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroSectionCard(
                    eyebrow: run.date,
                    title: run.title,
                    subtitle: "Completed run summary with route, splits, and heart rate breakdown."
                ) {
                    HStack(spacing: 12) {
                        MetricColumn(label: "Distance", value: run.distance)
                        MetricColumn(label: "Pace", value: run.averagePace)
                        MetricColumn(label: "Moving", value: run.movingTime)
                    }
                }

                SectionCard(title: "Summary", trailing: "Core metrics") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        MetricTile(label: "Elapsed", value: run.elapsedTime, detail: "total time", emphasis: .subdued)
                        MetricTile(label: "Avg HR", value: run.averageHeartRate, detail: "heart rate", accent: TurnoverPalette.warning, emphasis: .subdued)
                        MetricTile(label: "Elevation", value: run.elevationGain, detail: "gain", accent: TurnoverPalette.success, emphasis: .subdued)
                        MetricTile(label: "Splits", value: "\(run.splits.count)", detail: "captured", emphasis: .subdued)
                    }
                }

                SectionCard(title: "Route", trailing: "Preview") {
                    RoutePreview(shape: run.routeShape)
                        .frame(height: 140)
                }

                SectionCard(title: "Splits", trailing: "Sample data") {
                    VStack(spacing: 12) {
                        ForEach(run.splits) { split in
                            HStack {
                                Text(split.label)
                                    .foregroundStyle(TurnoverPalette.textPrimary)
                                Spacer()
                                Text(split.pace)
                                    .monospacedDigit()
                                    .foregroundStyle(TurnoverPalette.textPrimary)
                                Text(split.heartRate)
                                    .frame(width: 44, alignment: .trailing)
                                    .foregroundStyle(TurnoverPalette.textSecondary)
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.vertical, 4)

                            if split.id != run.splits.last?.id {
                                Capsule()
                                    .fill(TurnoverPalette.surfaceRaised)
                                    .frame(height: 1)
                            }
                        }
                    }
                }

                SectionCard(title: "Heart Rate Zones", trailing: "Z1-Z5") {
                    VStack(spacing: 12) {
                        ForEach(run.heartRateZones) { zone in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(zone.label)
                                        .foregroundStyle(TurnoverPalette.textPrimary)
                                    Spacer()
                                    Text(zone.duration)
                                        .foregroundStyle(TurnoverPalette.textSecondary)
                                        .monospacedDigit()
                                }

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(TurnoverPalette.surfaceRaised)
                                        Capsule()
                                            .fill(TurnoverPalette.accent)
                                            .frame(width: geometry.size.width * zone.fraction)
                                    }
                                }
                                .frame(height: 10)
                            }
                        }
                    }
                }

                if let personalRecord = run.personalRecord {
                    SectionCard(title: "Personal Record", trailing: "If earned") {
                        Text(personalRecord)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(TurnoverPalette.textPrimary)
                    }
                }
            }
            .padding(20)
        }
        .background(TurnoverPalette.background.ignoresSafeArea())
        .navigationTitle("Run Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsScreen: View {
    private let settings = TurnoverSampleData.settings

    var body: some View {
        TurnoverScreen(title: "Settings") {
            SectionCard(title: "Units") {
                SettingsRow(label: "Distance Unit", value: settings.distanceUnit)
                SettingsRow(label: "Split Unit", value: settings.splitUnit)
            }

            SectionCard(title: "Run Behavior") {
                HStack {
                    Text("Auto-Pause")
                        .foregroundStyle(TurnoverPalette.textPrimary)
                    Spacer()
                    Text(settings.autoPauseEnabled ? "On" : "Off")
                        .foregroundStyle(settings.autoPauseEnabled ? TurnoverPalette.accent : TurnoverPalette.textSecondary)
                }
            }

            SectionCard(title: "Heart Rate") {
                SettingsRow(label: "Zone Method", value: settings.zoneMethod)
                SettingsRow(label: "Max Heart Rate", value: settings.maxHeartRate)
            }

            SectionCard(title: "About") {
                SettingsRow(label: "App", value: "Turnover")
                SettingsRow(label: "Version", value: settings.version)
            }
        }
    }
}

struct MetricColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(TurnoverPalette.textSecondary)

            Text(value)
                .font(.headline)
                .foregroundStyle(TurnoverPalette.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecordRow: View {
    let label: String
    let value: String
    let detail: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(TurnoverPalette.textPrimary)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(TurnoverPalette.textPrimary)
            Text(detail)
                .foregroundStyle(TurnoverPalette.textSecondary)
        }
    }
}

struct RunHistoryRow: View {
    let run: RunSummary

    var body: some View {
        HStack(spacing: 14) {
            RoutePreview(shape: run.routeShape)
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 6) {
                Text(run.title)
                    .font(.headline)
                    .foregroundStyle(TurnoverPalette.textPrimary)

                Text(run.date)
                    .font(.subheadline)
                    .foregroundStyle(TurnoverPalette.textSecondary)

                HStack(spacing: 10) {
                    HistoryStat(value: run.distance)
                    HistoryStat(value: run.movingTime)
                    HistoryStat(value: run.averagePace)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(TurnoverPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(TurnoverPalette.surfaceMuted, lineWidth: 1)
        )
    }
}

struct HistoryStat: View {
    let value: String

    var body: some View {
        Text(value)
            .font(.caption.weight(.medium))
            .foregroundStyle(TurnoverPalette.textSecondary)
            .lineLimit(1)
    }
}

struct SettingsRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(TurnoverPalette.textPrimary)
            Spacer()
            Text(value)
                .foregroundStyle(TurnoverPalette.textSecondary)
        }
    }
}

struct RoutePreview: View {
    let shape: [Double]

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TurnoverPalette.background)

                Path { path in
                    guard let first = shape.first else { return }

                    path.move(to: CGPoint(x: 0, y: height * (1 - first)))

                    for (index, point) in shape.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(max(shape.count - 1, 1))
                        let y = height * (1 - point)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .strokedPath(.init(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [TurnoverPalette.accentMuted, TurnoverPalette.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(16)
            }
        }
    }
}

#Preview("Home") {
    NavigationStack {
        HomeScreen(onStartRun: {})
            .navigationDestination(for: RunSummary.self) { run in
                RunDetailScreen(run: run)
            }
    }
        .preferredColorScheme(.dark)
}

#Preview("Live Run") {
    LiveRunScreen(
        sessionPhase: .active,
        latestCompletedRun: TurnoverSampleData.featuredRun,
        onStartRun: {},
        onPauseRun: {},
        onResumeRun: {},
        onFinishRun: {},
        onViewLatestRun: {}
    )
        .preferredColorScheme(.dark)
}

#Preview("History") {
    NavigationStack {
        HistoryScreen()
            .navigationDestination(for: RunSummary.self) { run in
                RunDetailScreen(run: run)
            }
    }
        .preferredColorScheme(.dark)
}

#Preview("Run Detail") {
    NavigationStack {
        RunDetailScreen(run: TurnoverSampleData.featuredRun)
    }
    .preferredColorScheme(.dark)
}

#Preview("Settings") {
    SettingsScreen()
        .preferredColorScheme(.dark)
}
