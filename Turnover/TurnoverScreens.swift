//
//  TurnoverScreens.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

struct HomeScreen: View {
    let featuredRun: RunSummary?
    let historyMetrics: RunHistoryMetrics
    let onStartRun: () -> Void

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
                    MetricColumn(label: "Week", value: historyMetrics.weeklyDistanceSummary)
                    MetricColumn(label: "Month", value: historyMetrics.monthlyDistanceSummary)
                    MetricColumn(label: "Latest", value: historyMetrics.latestRunDistanceSummary)
                }
            }

            SectionCard(title: "This Week", trailing: "7 days") {
                HStack(spacing: 12) {
                    MetricTile(label: "Mileage", value: historyMetrics.weeklyDistanceValue, detail: "\(historyMetrics.distanceUnitLabel) logged", emphasis: .subdued)
                    MetricTile(label: "Month", value: historyMetrics.monthlyDistanceValue, detail: "\(historyMetrics.distanceUnitLabel) total", emphasis: .subdued)
                }

                HStack(spacing: 12) {
                    MetricTile(label: "Latest", value: historyMetrics.latestRunDistanceValue, detail: "\(historyMetrics.distanceUnitLabel) latest", accent: TurnoverPalette.success, emphasis: .subdued)
                    MetricTile(label: "PRs", value: "\(historyMetrics.personalRecordCount)", detail: "tagged runs", accent: TurnoverPalette.warning, emphasis: .subdued)
                }
            }

            if let featuredRun {
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
            }

            SectionCard(title: "Personal Records", trailing: "V1") {
                VStack(spacing: 12) {
                    ForEach(historyMetrics.personalRecords) { record in
                        RecordRow(
                            label: record.label,
                            value: DefaultRunSummaryBuilder.durationString(seconds: record.durationSeconds),
                            detail: record.achievedOn
                        )
                    }
                }
            }
        }
    }
}

struct LiveRunScreen: View {
    let runSession: RunSessionState
    let latestCompletedRun: RunSummary?
    let settings: SettingsSnapshot
    let platformStatus: RunPlatformStatus
    let onStartRun: () -> Void
    let onPauseRun: () -> Void
    let onResumeRun: () -> Void
    let onFinishRun: () -> Void
    let onViewLatestRun: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        TurnoverScreen(title: "Live Run") {
            switch runSession {
            case .idle:
                idleRunContent
            case .active(let session), .paused(let session):
                activeRunContent(session: session, isPaused: isPaused)
            case .completed:
                completedRunContent
            }
        }
    }

    private var isPaused: Bool {
        if case .paused = runSession {
            return true
        }

        return false
    }

    private var idleRunContent: some View {
        Group {
            HeroSectionCard(
                eyebrow: "Ready",
                title: "Start a session from here or jump in from Home.",
                subtitle: "Step 7 wires the run flow so the tab, session state, and summary route all behave like one app."
            ) {
                Button("Start Run", action: onStartRun)
                    .buttonStyle(PrimaryButtonStyle())
            }

            permissionRecoveryCard
        }
    }

    private func activeRunContent(session: ActiveRunSession, isPaused: Bool) -> some View {
        Group {
            SectionCard(title: isPaused ? "Paused" : "Active Run", trailing: platformStatus.liveStatusLabel) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(DefaultRunSummaryBuilder.durationString(seconds: session.snapshot.elapsedSeconds))
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
                    MetricTile(
                        label: "Distance",
                        value: distanceValue(for: session),
                        detail: session.settings.distanceUnit.shortLabel
                    )
                    MetricTile(
                        label: "Current Pace",
                        value: paceValue(secondsPerSplit: session.snapshot.currentPaceSecondsPerSplit),
                        detail: session.settings.splitUnit.shortLabel
                    )
                    MetricTile(
                        label: "Avg Pace",
                        value: paceValue(secondsPerSplit: session.snapshot.averagePaceSecondsPerSplit),
                        detail: session.settings.splitUnit.shortLabel
                    )
                    MetricTile(
                        label: "Heart Rate",
                        value: session.snapshot.heartRate.map(String.init) ?? "--",
                        detail: "bpm",
                        accent: TurnoverPalette.warning
                    )
                }
            }

            SectionCard(title: "Route", trailing: "Secondary") {
                RoutePreview(shape: session.snapshot.routeShape)
                    .frame(height: 120)
            }

            SectionCard(title: "Controls") {
                if isPaused {
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

            permissionRecoveryCard
        }
    }

    private var completedRunContent: some View {
        Group {
            HeroSectionCard(
                eyebrow: "Complete",
                title: "Run finished. Summary is ready.",
                subtitle: "The live tab is now driven by service-backed run state and summary generation."
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

    private func distanceValue(for session: ActiveRunSession) -> String {
        let unitDistance: Double

        switch session.settings.distanceUnit {
        case .kilometers:
            unitDistance = session.snapshot.distanceMeters / 1_000.0
        case .miles:
            unitDistance = session.snapshot.distanceMeters / 1_609.34
        }

        return String(format: "%.2f", unitDistance)
    }

    private func paceValue(secondsPerSplit: Double?) -> String {
        guard let secondsPerSplit else { return "--" }
        return DefaultRunSummaryBuilder.compactDurationString(seconds: Int(secondsPerSplit.rounded()))
    }

    @ViewBuilder
    private var permissionRecoveryCard: some View {
        if platformStatus.canOpenSettings {
            SectionCard(title: "Permissions", trailing: "Location") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location access is denied. Open Settings to re-enable GPS tracking for live runs.")
                        .font(.subheadline)
                        .foregroundStyle(TurnoverPalette.textSecondary)

                    Button("Open Settings", action: onOpenSettings)
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }
}

struct HistoryScreen: View {
    let runs: [RunSummary]
    let historyMetrics: RunHistoryMetrics

    var body: some View {
        TurnoverScreen(title: "History") {
            SectionCard(title: "Summary", trailing: "Recent") {
                HStack(spacing: 12) {
                    MetricTile(label: "Runs", value: "\(historyMetrics.runCount)", detail: "completed sessions")
                    MetricTile(label: "Mileage", value: historyMetrics.weeklyDistanceValue, detail: "\(historyMetrics.distanceUnitLabel) this week")
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
    let settings: SettingsSnapshot
    let onUpdateSettings: (SettingsSnapshot) -> Void

    var body: some View {
        TurnoverScreen(title: "Settings") {
            SectionCard(title: "Units") {
                PickerRow(
                    label: "Distance Unit",
                    identifier: "settings-distance-unit",
                    selection: settings.distanceUnit,
                    values: [.kilometers, .miles],
                    title: \.label,
                    onSelect: { selection in
                        onUpdateSettings(settings.updating(distanceUnit: selection))
                    }
                )
                PickerRow(
                    label: "Split Unit",
                    identifier: "settings-split-unit",
                    selection: settings.splitUnit,
                    values: [.kilometer, .mile],
                    title: \.label,
                    onSelect: { selection in
                        onUpdateSettings(settings.updating(splitUnit: selection))
                    }
                )
            }

            SectionCard(title: "Run Behavior") {
                HStack {
                    Text("Auto-Pause")
                        .foregroundStyle(TurnoverPalette.textPrimary)
                    Spacer()
                    Toggle(
                        "",
                        isOn: Binding(
                            get: { settings.autoPauseEnabled },
                            set: { onUpdateSettings(settings.updating(autoPauseEnabled: $0)) }
                        )
                    )
                    .labelsHidden()
                    .tint(TurnoverPalette.accent)
                    .accessibilityIdentifier("settings-auto-pause-toggle")
                }
            }

            SectionCard(title: "Heart Rate") {
                SettingsRow(label: "Zone Method", value: settings.zoneMethodLabel)
                StepperRow(
                    label: "Max Heart Rate",
                    identifier: "settings-max-heart-rate",
                    value: settings.maxHeartRate,
                    range: 120...230,
                    suffix: "bpm",
                    onChange: { selection in
                        onUpdateSettings(settings.updating(maxHeartRate: selection))
                    }
                )
            }

            SectionCard(title: "About") {
                SettingsRow(label: "App", value: "Turnover")
                SettingsRow(label: "Version", value: settings.version)
            }
        }
    }
}

private struct PickerRow<Value: Hashable>: View {
    let label: String
    let identifier: String
    let selection: Value
    let values: [Value]
    let title: KeyPath<Value, String>
    let onSelect: (Value) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .foregroundStyle(TurnoverPalette.textPrimary)

            Picker(label, selection: Binding(get: { selection }, set: onSelect)) {
                ForEach(values, id: \.self) { value in
                    Text(value[keyPath: title]).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(identifier)
        }
    }
}

private struct StepperRow: View {
    let label: String
    let identifier: String
    let value: Int
    let range: ClosedRange<Int>
    let suffix: String
    let onChange: (Int) -> Void

    var body: some View {
        Stepper(value: Binding(get: { value }, set: onChange), in: range) {
            HStack {
                Text(label)
                    .foregroundStyle(TurnoverPalette.textPrimary)
                Spacer()
                Text("\(value) \(suffix)")
                    .foregroundStyle(TurnoverPalette.textSecondary)
            }
        }
        .tint(TurnoverPalette.accent)
        .accessibilityIdentifier(identifier)
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
            let previewShape = RoundedRectangle(cornerRadius: 18, style: .continuous)
            let contentInset: CGFloat = 16
            let strokeWidth: CGFloat = 6
            let drawableMinX = contentInset + strokeWidth / 2
            let drawableMaxX = width - contentInset - strokeWidth / 2
            let drawableMinY = contentInset + strokeWidth / 2
            let drawableMaxY = height - contentInset - strokeWidth / 2
            let drawableWidth = max(drawableMaxX - drawableMinX, 0)
            let drawableHeight = max(drawableMaxY - drawableMinY, 0)

            ZStack {
                previewShape
                    .fill(TurnoverPalette.background)

                Path { path in
                    guard let first = shape.first else { return }

                    path.move(
                        to: CGPoint(
                            x: drawableMinX,
                            y: drawableMinY + drawableHeight * (1 - first)
                        )
                    )

                    for (index, point) in shape.enumerated() {
                        let x = drawableMinX + drawableWidth * CGFloat(index) / CGFloat(max(shape.count - 1, 1))
                        let y = drawableMinY + drawableHeight * (1 - point)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .strokedPath(.init(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [TurnoverPalette.accentMuted, TurnoverPalette.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .clipShape(previewShape)
        }
    }
}

#Preview("Home") {
    NavigationStack {
        HomeScreen(
            featuredRun: TurnoverSampleData.featuredRun,
            historyMetrics: DefaultRunMetricsCalculator().summarizeHistory(
                TurnoverSampleData.recentRuns,
                using: TurnoverSampleData.settings.runSettings,
                now: TurnoverSampleData.featuredRun.startedAt
            ),
            onStartRun: {}
        )
            .navigationDestination(for: RunSummary.self) { run in
                RunDetailScreen(run: run)
            }
    }
        .preferredColorScheme(.dark)
}

#Preview("Live Run") {
    LiveRunScreen(
        runSession: .active(
            ActiveRunSession(
                id: UUID(),
                startedAt: Date(),
                settings: TurnoverSampleData.settings.runSettings,
                snapshot: RunTrackingSnapshot(
                    elapsedSeconds: 2_600,
                    movingSeconds: 2_590,
                    distanceMeters: 8_420,
                    currentPaceSecondsPerSplit: 298,
                    averagePaceSecondsPerSplit: 308,
                    heartRate: 162,
                    elevationGainMeters: 124,
                    routeShape: TurnoverSampleData.featuredRun.routeShape
                )
            )
        ),
        latestCompletedRun: TurnoverSampleData.featuredRun,
        settings: TurnoverSampleData.settings,
        platformStatus: MockRunPlatformStatusProvider().currentPlatformStatus(),
        onStartRun: {},
        onPauseRun: {},
        onResumeRun: {},
        onFinishRun: {},
        onViewLatestRun: {},
        onOpenSettings: {}
    )
        .preferredColorScheme(.dark)
}

#Preview("History") {
    NavigationStack {
        HistoryScreen(
            runs: TurnoverSampleData.recentRuns,
            historyMetrics: DefaultRunMetricsCalculator().summarizeHistory(
                TurnoverSampleData.recentRuns,
                using: TurnoverSampleData.settings.runSettings,
                now: TurnoverSampleData.featuredRun.startedAt
            )
        )
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
    SettingsScreen(settings: TurnoverSampleData.settings, onUpdateSettings: { _ in })
        .preferredColorScheme(.dark)
}
