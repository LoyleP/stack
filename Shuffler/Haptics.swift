import UIKit

class Haptics {
    static let shared = Haptics()
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    init() { light.prepare(); medium.prepare(); heavy.prepare() }
    
    // Original generic method
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light: light.impactOccurred()
        case .medium: medium.impactOccurred()
        case .heavy: heavy.impactOccurred()
        default: medium.impactOccurred()
        }
    }

    // --- NEW: Semantic methods for easier tuning ---

    /// Triggered when the shuffle sequence begins
    func shuffleStart() {
        heavy.impactOccurred()
    }

    /// Triggered every time a card "tucks" to the bottom
    func shuffleTuck() {
        medium.impactOccurred()
    }

    /// Triggered when the shuffle ends and a winner is revealed
    func shuffleSuccess() {
        heavy.impactOccurred()
    }
    
    func selectionRemoved() {
            medium.impactOccurred()
    }
}
