import AVFoundation
import UIKit

/// Spoken cues and haptics during workouts.
@MainActor
final class Coach {
    static let shared = Coach()
    private let synth = AVSpeechSynthesizer()
    var enabled = true

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [.duckOthers, .mixWithOthers])
    }

    func say(_ text: String) {
        guard enabled else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.52
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }

    func tick() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
}
