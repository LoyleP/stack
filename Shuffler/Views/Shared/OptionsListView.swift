import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Binding var isPresented: Bool // Compatibility for DeckView
    
    @EnvironmentObject var store: DeckStore
    @State private var showSaveDialog = false
    @State private var deckName = ""
    @State private var newOptionText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showClearConfirmation = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.07).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Deck Options").font(Orbit.headingFont()).foregroundStyle(.white)
                    Spacer()
                    
                    // Bookmark for Saving
                    if !items.isEmpty {
                        Button(action: {
                            withAnimation(Orbit.Dynamics.element) { showSaveDialog = true }
                        }) {
                            Image(systemName: "bookmark.fill").font(.system(size: 16, weight: .bold))
                        }
                        .buttonStyle(.orbitGlass)
                        .padding(.trailing, 8)
                    }
                    
                    // NEW: Close button for the drawer
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(.orbitGlass)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24) // Reset padding for drawer context
                .padding(.bottom, 20)
                
                // Card Content
                VStack {
                    if items.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                HStack {
                                    Button("Clear All") {
                                        withAnimation(Orbit.Dynamics.element) { showClearConfirmation = true }
                                    }
                                    .font(.caption).foregroundStyle(.red)
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .padding(.bottom, 4)

                                ForEach(items) { item in
                                    itemRow(for: item)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
                
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: addOption, onShuffle: {})
                    .padding(20)
            }
            .blur(radius: (showClearConfirmation || showSaveDialog) ? 10 : 0)
            
            if showClearConfirmation { clearAlertOverlay }
            if showSaveDialog { saveDeckOverlay }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Components
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 50)).foregroundStyle(.white.opacity(0.2))
            Text("No options yet").font(Orbit.bodyFont()).foregroundStyle(.white.opacity(0.4))
            Spacer()
        }
    }

    private func itemRow(for item: Item) -> some View {
        HStack {
            Circle().fill(item.color).frame(width: 12, height: 12)
            Text(item.text).font(Orbit.bodyFont()).foregroundStyle(.white)
            Spacer()
            
            Button(action: { deleteItem(item) }) {
                Image(systemName: "xmark.circle.fill").font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.2))
            }
        }
        .padding(20)
        .background(Orbit.glassMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Orbit.glassBorder, lineWidth: 1))
    }

    private var clearAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture {
                withAnimation(Orbit.Dynamics.element) { showClearConfirmation = false }
            }
            VStack(spacing: 24) {
                Text("Clear everything?").font(Orbit.headingFont())
                HStack(spacing: 16) {
                    Button("Cancel") { withAnimation(Orbit.Dynamics.element) { showClearConfirmation = false } }.buttonStyle(.plain)
                    Button("Clear All") {
                        withAnimation(Orbit.Dynamics.element) {
                            items.removeAll()
                            showClearConfirmation = false
                        }
                    }.foregroundStyle(.red)
                }
            }
            .padding(24).background(Orbit.glassMaterial).clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private var saveDeckOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().onTapGesture {
                withAnimation(Orbit.Dynamics.element) { showSaveDialog = false }
            }
            VStack(spacing: 20) {
                Text("Save current deck").font(Orbit.headingFont())
                TextField("Deck Name", text: $deckName)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                
                HStack(spacing: 16) {
                    Button("Cancel") { withAnimation(Orbit.Dynamics.element) { showSaveDialog = false } }.buttonStyle(.plain)
                    Button("Save") {
                        store.saveCurrentDeck(name: deckName, items: items)
                        deckName = ""
                        withAnimation(Orbit.Dynamics.element) { showSaveDialog = false }
                        Haptics.shared.play(.medium)
                    }
                    .font(.headline)
                    .disabled(deckName.isEmpty)
                }
            }
            .padding(24).background(Orbit.glassMaterial).clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(40)
        }
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        withAnimation(Orbit.Dynamics.element) { items.insert(Item(text: newOptionText, colorName: Theme.randomColorName()), at: 0) }
        newOptionText = ""
    }
    
    func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(Orbit.Dynamics.element) { items.remove(at: index) }
            Haptics.shared.selectionRemoved()
        }
    }
}
