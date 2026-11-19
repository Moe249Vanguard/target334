import SwiftUI
import UIKit

/// Calm palette grounded in colour psychology:
/// sage/spruce greens for calm and growth, sky blue for rest and recovery,
/// low-glare mist neutrals, and warm apricot reserved for achievements.
/// Every colour adapts to light and dark mode.
enum Theme {
    static let bg = Color(light: 0xEDF2EF, dark: 0x0F1716)
    static let surface = Color(light: 0xF9FBFA, dark: 0x16211F)
    static let surface2 = Color(light: 0xE3EBE7, dark: 0x1D2B28)
    static let line = Color(light: 0xD5E0DC, dark: 0x26362F)
    static let primary = Color(light: 0x2F6F68, dark: 0x7CC4B5)
    static let primarySoft = Color(light: 0xD8EAE4, dark: 0x1E3833)
    static let onPrimary = Color(light: 0xF4FAF8, dark: 0x0E1B18)
    static let sky = Color(light: 0x5E8DB5, dark: 0x8DB6D8)
    static let skySoft = Color(light: 0xDCE8F2, dark: 0x1C2C3A)
    static let apricot = Color(light: 0xD88A57, dark: 0xEDB089)
    static let apricotSoft = Color(light: 0xF6E2D3, dark: 0x3A2A1F)
    static let warn = Color(light: 0xB7792F, dark: 0xE3B06A)

    static func categoryColor(_ c: ExerciseCategory) -> Color {
        switch c {
        case .warmup: return Color(light: 0xD08A57, dark: 0xE2A57A)
        case .push: return Color(light: 0xB86E7C, dark: 0xD891A0)
        case .pull: return Color(light: 0x5E8DB5, dark: 0x8DB6D8)
        case .legs: return Color(light: 0x8178B8, dark: 0xA9A0DC)
        case .core: return Color(light: 0x5E9A7A, dark: 0x86C1A0)
        case .conditioning: return Color(light: 0xC9775E, dark: 0xE09A82)
        case .mobility: return Color(light: 0x3F9690, dark: 0x6CC1BA)
        }
    }

    static func toneColors(_ tone: CoachAdvice.Tone) -> (fill: Color, icon: Color) {
        switch tone {
        case .go: return (primarySoft, primary)
        case .rest: return (skySoft, sky)
        case .win: return (apricotSoft, apricot)
        }
    }
}

extension Color {
    /// A colour that switches between two hex values with the system appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 0xFF) / 255,
                           green: CGFloat((hex >> 8) & 0xFF) / 255,
                           blue: CGFloat(hex & 0xFF) / 255,
                           alpha: 1)
        })
    }
}

extension View {
    /// Calm mist background behind lists, forms and scroll views.
    func calmBackground() -> some View {
        scrollContentBackground(.hidden).background(Theme.bg.ignoresSafeArea())
    }
}

struct Card<Content: View>: View {
    var fill: Color = Theme.surface
    var bordered = true
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.line, lineWidth: bordered ? 1 : 0))
    }
}

struct Chip: View {
    let text: String
    var color: Color = .secondary
    var fill: Color = Theme.surface2

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .foregroundStyle(color)
            .background(fill, in: Capsule())
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = Theme.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.line, lineWidth: 1))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Theme.primary.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(Theme.onPrimary)
    }
}

struct SoftButtonStyle: ButtonStyle {
    var tint: Color = Theme.primary
    var fill: Color = Theme.primarySoft

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(fill.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(tint)
    }
}

/// Circular countdown used by the workout player.
struct ProgressRing<Center: View>: View {
    let progress: Double      // 1 = full, 0 = empty
    var color: Color = Theme.primary
    var track: Color = Theme.surface2
    var breathing = false
    @ViewBuilder var center: Center
    @State private var expanded = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if breathing {
                Circle()
                    .fill(color.opacity(0.18))
                    .padding(36)
                    .scaleEffect(expanded || reduceMotion ? 1 : 0.72)
                    .onAppear {
                        guard !reduceMotion else { return }
                        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { expanded = true }
                    }
            }
            Circle().stroke(track, lineWidth: 12)
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: progress)
            center
        }
        .frame(width: 240, height: 240)
        .frame(maxWidth: .infinity)
    }
}

extension Int {
    var mmss: String { String(format: "%d:%02d", self / 60, self % 60) }
}
