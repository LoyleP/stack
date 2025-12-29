import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Environment(\.dismiss) var dismiss
    @State private var newOptionText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.12, green: 0.12, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // HEADER
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.orbitGlass)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    // LIST
                    if items.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "square.stack.3d.up.slash")
                                .font(.system(size: 60))
                                .foregroundStyle(.white.opacity(0.2))
                            Text("Your deck is empty.")
                                .font(Orbit.headingFont())
                                .foregroundStyle(.white.opacity(0.5))
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(items) { item in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 14, height: 14)
                                        .shadow(color: item.color.opacity(0.6), radius: 4, x: 0, y: 0)
                                    
                                    Text(item.text)
                                        .font(Orbit.bodyFont())
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: { deleteItem(item) }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.7))
                                            .frame(width: 32, height: 32)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 12)
                                .padding(.leading, 20)
                                .padding(.trailing, 12)
                                .background(Orbit.glassMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Orbit.glassBorder, lineWidth: Orbit.glassBorderWidth)
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        // THE UX FIX: Dismiss keyboard when dragging list
                        .scrollDismissesKeyboard(.interactively)
                    }
                    
                    // INPUT BAR
                    ControlBar(
                        text: $newOptionText,
                        onAdd: addOption,
                        onShuffle: {}
                    )
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
    
    func addOption() {
        guard !newOptionText.isEmpty else { return }
        let newItem = Item(text: newOptionText, colorName: Theme.randomColorName())
        
        withAnimation(.spring()) {
            items.insert(newItem, at: 0)
        }
        newOptionText = ""
    }
    
    func deleteItem(_ item: Item) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items.removeAll { $0.id == item.id }
        }
    }
}
