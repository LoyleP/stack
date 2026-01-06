import SwiftUI

struct Theme {
    static let colorNames: [String] = [
        "forest", "denim", "terracotta", "mustard", "plum", "ocean", "amber", "berry"
    ]
    
    static func color(for name: String) -> Color {
        switch name {
        case "forest":     return Color(red: 0.25, green: 0.65, blue: 0.35)
        case "denim":      return Color(red: 0.25, green: 0.55, blue: 0.95)
        case "terracotta": return Color(red: 0.90, green: 0.40, blue: 0.30)
        case "mustard":    return Color(red: 0.95, green: 0.75, blue: 0.15)
        case "plum":       return Color(red: 0.70, green: 0.30, blue: 0.75)
        case "ocean":      return Color(red: 0.15, green: 0.75, blue: 0.85)
        case "amber":      return Color(red: 0.95, green: 0.55, blue: 0.15)
        case "berry":      return Color(red: 0.85, green: 0.25, blue: 0.50)
        default:           return Color(red: 0.25, green: 0.55, blue: 0.95)
        }
    }
    
    static func randomColorName() -> String {
        colorNames.randomElement() ?? "denim"
    }
    
    static func gradient(for color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
