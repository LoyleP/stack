import SwiftUI

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let colorName: String
    let rotation: Double // <--- Now we save this specific angle
    
    var color: Color {
        Theme.color(for: colorName)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text, colorName, rotation // <--- Added to the save list
    }
    
    init(text: String, colorName: String) {
        self.id = UUID()
        self.text = text
        self.colorName = colorName
        self.rotation = Double.random(in: -5...5) // Calculated once on creation, then kept forever
    }
}
