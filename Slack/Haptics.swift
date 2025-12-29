import UIKit

class Haptics {
    static let shared = Haptics()
    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    init() { light.prepare(); medium.prepare(); heavy.prepare() }
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light: light.impactOccurred()
        case .medium: medium.impactOccurred()
        case .heavy: heavy.impactOccurred()
        default: medium.impactOccurred()
        }
    }
}
