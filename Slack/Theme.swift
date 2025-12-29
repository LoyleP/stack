import SwiftUI

struct Theme {
    static let colorNames: [String] = ["indigo", "purple", "pink", "orange", "teal", "blue", "mint", "red"]
    
    static func color(for name: String) -> Color {
        switch name {
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        case "teal": return .teal
        case "blue": return .blue
        case "mint": return .mint
        case "red": return .red
        default: return .blue
        }
    }
    
    static func randomColorName() -> String { colorNames.randomElement() ?? "blue" }
    
    static func gradient(for color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
