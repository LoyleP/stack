import SwiftUI
import Combine

class DeckStore: ObservableObject {
    @Published var savedDecks: [Deck] = []
    @Published var activeDeck: Deck
    
    private let saveKey = "shuffler_saved_decks"
    private let activeKey = "shuffler_active_deck"

    init() {
        // Load Saved Decks
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Deck].self, from: data) {
            self.savedDecks = decoded
        }
        
        // Load or Initialize Active Deck
        if let data = UserDefaults.standard.data(forKey: activeKey),
           let decoded = try? JSONDecoder().decode(Deck.self, from: data) {
            self.activeDeck = decoded
        } else {
            self.activeDeck = Deck(name: "Current Deck", items: [
                Item(text: "Non", colorName: "terracotta"),
                Item(text: "Oui", colorName: "denim")
            ])
        }
    }

    func saveAll() {
        if let savedData = try? JSONEncoder().encode(savedDecks) {
            UserDefaults.standard.set(savedData, forKey: saveKey)
        }
        if let activeData = try? JSONEncoder().encode(activeDeck) {
            UserDefaults.standard.set(activeData, forKey: activeKey)
        }
    }

    func saveCurrentAsNew(name: String) {
        let newDeck = Deck(name: name, items: activeDeck.items)
        savedDecks.append(newDeck)
        saveAll()
    }

    func deleteDeck(at offsets: IndexSet) {
        savedDecks.remove(atOffsets: offsets)
        saveAll()
    }
    
    func selectDeck(_ deck: Deck) {
        activeDeck = deck
        saveAll()
    }
}
