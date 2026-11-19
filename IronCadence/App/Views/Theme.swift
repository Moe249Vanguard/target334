import SwiftUI

enum Theme {
    static let olive = Color(red: 0.42, green: 0.49, blue: 0.27)
    static let darkOlive = Color(red: 0.20, green: 0.24, blue: 0.13)
    static let sand = Color(red: 0.80, green: 0.72, blue: 0.52)
    static let ranger = Color(red: 0.93, green: 0.55, blue: 0.20)

    static func categoryColor(_ c: ExerciseCategory) -> Color {
        switch c {
        case .warmup: return .orange
        case .push: return .red
        case .pull: return .blue
        case .legs: return .purple
        case .core: return olive
        case .conditioning: return .pink
        case .mobility: return .teal
        }
    }
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = Theme.olive

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.olive.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
    }
}

extension Int {
    var mmss: String { String(format: "%d:%02d", self / 60, self % 60) }
}
