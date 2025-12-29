import UIKit

class Haptics {
    static let shared = Haptics()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    init() {
        // "Prepare" reduces the latency (lag) of the first vibration
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
    }
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.impactOccurred()
        default:
            mediumGenerator.impactOccurred()
        }
    }
}
