import SwiftUI

struct SavedDecksView: View {
    @EnvironmentObject var store: DeckStore
    @Binding var isPresented: Bool
    var onSelect: ([Item]) -> Void
    
    var body: some View {
        ZStack {
            // FIX: Added ignoresSafeArea to remove black zones
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Saved Decks").font(Orbit.headingFont()).foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 40) // Unified header top padding
                .padding(.bottom, 20)
                
                if store.savedDecks.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) { // Unified card spacing
                            ForEach(store.savedDecks) { deck in
                                deckRow(for: deck)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Breathing room above Tab Bar
                        
                    }
                }
            }
        }
    }

    // Add this helper to keep the body clean
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray").font(.system(size: 40)).foregroundStyle(.white.opacity(0.2))
            Text("No saved decks yet").font(Orbit.bodyFont()).foregroundStyle(.white.opacity(0.3))
        }
    }

    private func deckRow(for deck: Deck) -> some View {
        Button(action: { onSelect(deck.items); Haptics.shared.play(.medium) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name).font(Orbit.bodyFont()).foregroundStyle(.white)
                    Text("\(deck.items.count) options").font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundStyle(.white.opacity(0.2))
            }
            .padding(20)
            .background(Orbit.glassMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Orbit.glassBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
