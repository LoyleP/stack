import Foundation

struct Deck: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var items: [Item]
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, items: [Item] = []) {
        self.id = id
        self.name = name
        self.items = items
        self.createdAt = Date()
    }
}
