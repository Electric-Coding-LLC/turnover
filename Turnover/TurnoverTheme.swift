//
//  TurnoverTheme.swift
//  Turnover
//
//  Created by iamce on 3/31/26.
//

import SwiftUI

enum TurnoverPalette {
    static let background = Color(red: 0.06, green: 0.07, blue: 0.09)
    static let surface = Color(red: 0.10, green: 0.11, blue: 0.14)
    static let surfaceRaised = Color(red: 0.14, green: 0.16, blue: 0.20)
    static let surfaceMuted = Color(red: 0.17, green: 0.19, blue: 0.24)
    static let accent = Color(red: 0.00, green: 0.87, blue: 0.95)
    static let accentMuted = Color(red: 0.00, green: 0.45, blue: 0.50)
    static let success = Color(red: 0.34, green: 0.84, blue: 0.64)
    static let warning = Color(red: 1.00, green: 0.49, blue: 0.26)
    static let textPrimary = Color(red: 0.91, green: 0.92, blue: 0.95)
    static let textSecondary = Color(red: 0.62, green: 0.66, blue: 0.74)
}

struct TurnoverScreen<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    content
                }
                .padding(20)
            }
            .background(TurnoverPalette.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let trailing: String?
    let content: Content

    init(title: String, trailing: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.trailing = trailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(TurnoverPalette.textPrimary)

                Spacer()

                if let trailing {
                    Text(trailing)
                        .font(.caption)
                        .textCase(.uppercase)
                        .foregroundStyle(TurnoverPalette.textSecondary)
                }
            }

            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TurnoverPalette.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TurnoverPalette.surfaceRaised, lineWidth: 1)
        )
    }
}

struct MetricTile: View {
    let label: String
    let value: String
    let detail: String
    var accent: Color = TurnoverPalette.accent
    var emphasis: MetricTileEmphasis = .regular

    enum MetricTileEmphasis {
        case regular
        case subdued
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(TurnoverPalette.textSecondary)

            Text(value)
                .font(.system(size: emphasis == .regular ? 30 : 24, weight: .bold, design: .rounded))
                .foregroundStyle(TurnoverPalette.textPrimary)
                .minimumScaleFactor(0.7)

            Text(detail)
                .font(.caption)
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            emphasis == .regular ? TurnoverPalette.surfaceRaised : TurnoverPalette.surfaceMuted,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

struct HeroSectionCard<Content: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let content: Content

    init(eyebrow: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(TurnoverPalette.accent)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(TurnoverPalette.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(TurnoverPalette.textSecondary)
            }

            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [TurnoverPalette.surfaceRaised, TurnoverPalette.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(TurnoverPalette.surfaceMuted, lineWidth: 1)
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(configuration.isPressed ? TurnoverPalette.accentMuted : TurnoverPalette.accent)
            )
            .foregroundStyle(TurnoverPalette.background)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TurnoverPalette.surfaceRaised)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(configuration.isPressed ? TurnoverPalette.accent : TurnoverPalette.surfaceRaised, lineWidth: 1)
            )
            .foregroundStyle(TurnoverPalette.textPrimary)
    }
}

#Preview("Theme") {
    TurnoverScreen(title: "Preview") {
        SectionCard(title: "Metrics", trailing: "Sample") {
            HStack {
                MetricTile(label: "Distance", value: "8.42", detail: "km today")
                MetricTile(label: "Pace", value: "5'08", detail: "avg")
            }
        }
    }
    .preferredColorScheme(.dark)
}
