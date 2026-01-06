import SwiftUI
import Combine

class DeckStore: ObservableObject {
    @Published var savedDecks: [Deck] = []
    private let saveKey = "shuffler_saved_decks"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Deck].self, from: data) {
            self.savedDecks = decoded
        }
    }

    func saveCurrentDeck(name: String, items: [Item]) {
        let newDeck = Deck(name: name, items: items)
        savedDecks.append(newDeck)
        persist()
    }

    func deleteDeck(at indexSet: IndexSet) {
        savedDecks.remove(atOffsets: indexSet)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(savedDecks) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}
