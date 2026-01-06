import SwiftUI

struct SavedDecksView: View {
    @EnvironmentObject var store: DeckStore
    @Binding var selectedTab: Int
    @State private var showingSaveAlert = false
    @State private var newDeckName = ""

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("My Decks").font(Orbit.headingFont()).foregroundStyle(.white)
                    Spacer()
                    Button(action: { showingSaveAlert = true }) {
                        Image(systemName: "plus.circle.fill").font(.title2).foregroundStyle(Theme.color(for: "denim"))
                    }
                }
                .padding(.horizontal, 20).padding(.top, 20)

                if store.savedDecks.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.savedDecks) { deck in
                                deckRow(for: deck)
                            }
                        }
                        .padding(20)
                    }
                }
                Spacer()
            }
        }
        .alert("Save Current Deck", isPresented: $showingSaveAlert) {
            TextField("Deck Name", text: $newDeckName)
            Button("Save") {
                store.saveCurrentAsNew(name: newDeckName)
                newDeckName = ""
            }
            Button("Cancel", role: .cancel) { newDeckName = "" }
        } message: {
            Text("Enter a name for your current set of options.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray.full").font(.system(size: 40)).foregroundStyle(.white.opacity(0.2))
            Text("No saved decks yet.").font(Orbit.bodyFont()).foregroundStyle(.white.opacity(0.4))
            Spacer()
        }
    }

    private func deckRow(for deck: Deck) -> some View {
        Button(action: {
            store.selectDeck(deck)
            withAnimation(Orbit.Dynamics.panel) { selectedTab = 0 }
            Haptics.shared.play(.medium)
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.name).font(Orbit.bodyFont()).foregroundStyle(.white)
                    Text("\(deck.items.count) options").font(.caption).foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundStyle(.white.opacity(0.3))
            }
            .padding(20)
            .background(Orbit.glassMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth))
        }
        .buttonStyle(.plain)
    }
}
