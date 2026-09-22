import SwiftUI

/// One station on the shift board: what it reads now and when it was last checked.
/// The board is composed from these tiles, so `state` has to be visible without the
/// screen re-reading the text.
struct StatusTile: View {
    enum State {
        case ok
        case watch
        case fault

        var tint: Color {
            switch self {
            case .ok:
                return AppTheme.accent
            case .watch:
                return AppTheme.textMono
            case .fault:
                return AppTheme.danger
            }
        }
    }

    let station: String
    let reading: String
    let stamp: String
    var state: State = .ok

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.contentSpacing) {
            HStack(spacing: AppMetrics.tightSpacing) {
                Capsule()
                    .fill(state.tint)
                    .frame(width: AppMetrics.tightSpacing, height: AppMetrics.tightSpacing)
                    .accessibilityHidden(true)

                Text(station)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Text(reading)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(stamp)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
        }
        .frame(minWidth: AppMetrics.tileMinWidth, alignment: .leading)
        .cardSurface(padding: AppMetrics.cardPadding)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ScreenScaffold {
        HStack(spacing: AppMetrics.contentSpacing) {
            StatusTile(station: "Fridge #2", reading: "4 °C", stamp: "checked 22:14")
            StatusTile(
                station: "Kegs",
                reading: "low",
                stamp: "IPA · dark lager",
                state: .watch
            )
        }
    }
}
