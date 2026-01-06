import SwiftUI
import Combine

@MainActor
class DeckViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isShuffling = false
    @Published var activeShuffleId: UUID? = nil
    @Published var sparkleTrigger = 0
    @Published var usedSessionColors: Set<String> = []
    @Published var cardOffsets: [UUID: CGFloat] = [:]
    
    private var originalTopId: UUID? = nil
    private var shuffleTask: Task<Void, Never>? = nil

    init() { loadItems() }

    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            self.items = decoded
        } else {
            self.items = [Item(text: "Non", colorName: "terracotta"), Item(text: "Oui", colorName: "denim")]
        }
    }

    func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "savedItems")
        }
    }

    func addOption(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }
        if items.contains(where: { $0.text.lowercased() == cleanText.lowercased() }) { return }
        let picked = Theme.colorNames.filter { !usedSessionColors.contains($0) }.randomElement() ?? Theme.randomColorName()
        usedSessionColors.insert(picked)
        withAnimation(Orbit.Dynamics.element) { items.append(Item(text: cleanText, colorName: picked)) }
        saveItems()
    }

    // --- OPTIMIZED SHUFFLE ENGINE ---
    func startContinuousShuffle() {
        guard !items.isEmpty && !isShuffling else { return }
        originalTopId = items.last?.id
        withAnimation(Orbit.Dynamics.element) { isShuffling = true }
        Haptics.shared.shuffleStart()
        
        shuffleTask = Task {
            while !Task.isCancelled {
                guard let topItem = items.last else { break }
                let idToMove = topItem.id
                
                withAnimation(Orbit.Dynamics.element) {
                    activeShuffleId = idToMove
                    cardOffsets[idToMove] = 450
                }
                
                try? await Task.sleep(nanoseconds: 120_000_000)
                Haptics.shared.shuffleTuck()
                
                // FIX: Explicitly animate the data reordering
                withAnimation(Orbit.Dynamics.physics) {
                    if let index = items.firstIndex(where: { $0.id == idToMove }) {
                        let card = items.remove(at: index)
                        items.insert(card, at: 0)
                    }
                }
                
                withAnimation(Orbit.Dynamics.physics) { cardOffsets[idToMove] = 0 }
                try? await Task.sleep(nanoseconds: 150_000_000)
                activeShuffleId = nil
            }
        }
    }

    func endContinuousShuffle() {
        guard isShuffling else { return }
        shuffleTask?.cancel(); shuffleTask = nil
        Haptics.shared.shuffleSuccess()
        let candidates = items.filter { $0.id != originalTopId }
        let winner = (candidates.randomElement() ?? items.randomElement())!
        var remaining = items.filter { $0.id != winner.id }; remaining.shuffle()
        withAnimation(Orbit.Dynamics.physics) {
            items = remaining + [winner]
            isShuffling = false
            cardOffsets.removeAll()
            activeShuffleId = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.sparkleTrigger += 1 }
    }

    func performShortShuffle() {
        if !isShuffling {
            startContinuousShuffle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.endContinuousShuffle() }
        }
    }
}
