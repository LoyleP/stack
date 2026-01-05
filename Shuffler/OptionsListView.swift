import SwiftUI

struct OptionsListView: View {
    @Binding var items: [Item]
    @Environment(\.dismiss) var dismiss
    @State private var newOptionText = ""
    @State private var usedSessionColors: Set<String> = []
    @FocusState private var isInputFocused: Bool
    @State private var showClearConfirmation = false

    // NEW: Access the onboarding state for testing
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()

            VStack(spacing: 20) {
                // 1. Header Row
                HStack {
                    if !items.isEmpty {
                        Button(action: {
                            withAnimation(Orbit.touch) {
                                showClearConfirmation = true
                            }
                            Haptics.shared.play(.light)
                        }) {
                            Text("Clear All")
                                .font(Orbit.bodyFont())
                                .foregroundStyle(.red.opacity(0.8))
                        }
                        .padding(.leading, 4)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.orbitGlass)
                }

                // 2. Content Area
                VStack {
                    if items.isEmpty {
                        Spacer()
                        VStack(spacing: 32) {
                            VStack(spacing: 16) {
                                Image(systemName: "square.stack.3d.up.slash")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white.opacity(0.2))
                                Text("Your deck is empty.")
                                    .font(Orbit.headingFont())
                                    .foregroundStyle(.white.opacity(0.5))
                            }

                            // Debug toggle even when empty
                            debugSection
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(items) { item in
                                    itemRow(for: item)
                                }

                                // Debug toggle at the end of the list
                                debugSection
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                }

                // Input Bar
                ControlBar(
                    text: $newOptionText,
                    focusState: $isInputFocused,
                    onAdd: addOption,
                    onShuffle: {}
                )
            }
            .padding(16)
            .blur(radius: showClearConfirmation ? 10 : 0)  // Blur content when alert is active

            // 2. FLOATING CENTERED ALERT
            if showClearConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showClearConfirmation = false }
                    }

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Clear Deck?")
                            .font(Orbit.headingFont())
                        Text("This will remove all options permanently.")
                            .font(Orbit.bodyFont())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.spring()) {
                                items.removeAll()
                                showClearConfirmation = false
                                Haptics.shared.selectionRemoved()
                            }
                        }) {
                            Text("Clear All")
                                .font(Orbit.bodyFont())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .clipShape(Capsule())
                        }

                        Button(action: {
                            withAnimation { showClearConfirmation = false }
                        }) {
                            Text("Cancel")
                                .font(Orbit.bodyFont())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Orbit.glassMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(
                                        Orbit.glassBorder,
                                        lineWidth: Orbit.glassBorderWidth
                                    )
                                )
                        }
                    }
                }
                .padding(24)
                .background(Orbit.glassMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(
                            Orbit.glassBorder,
                            lineWidth: Orbit.glassBorderWidth
                        )
                )
                .padding(.horizontal, 40)
                .transition(.scale(scale: 0.9).combined(with: .opacity))  // Centered scale transition
                .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { usedSessionColors.removeAll() }
    }

    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DEVELOPER SETTINGS")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.leading, 12)

            HStack {
                Image(systemName: "eye.fill")
                    .foregroundStyle(Theme.color(for: "denim"))

                Text("Show Onboarding")
                    .font(Orbit.bodyFont())
                    .foregroundStyle(.white)

                Spacer()

                // Toggle inverted logic: ON means hasSeenOnboarding = false
                Toggle(
                    "",
                    isOn: Binding(
                        get: { !hasSeenOnboarding },
                        set: { hasSeenOnboarding = !$0 }
                    )
                )
                .labelsHidden()
                .tint(Theme.color(for: "denim"))  // Using Theme denim blue
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
        }
        .padding(.top, 24)
        .padding(.horizontal, 4)
    }

    // --- Row View remains the same as previously defined ---
    func itemRow(for item: Item) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(item.color)
                .frame(width: 22, height: 22)
                .shadow(color: item.color.opacity(0.6), radius: 4)

            Text(item.text)
                .font(Orbit.bodyFont())
                .foregroundStyle(.white)

            Spacer()

            Button(action: {
                withAnimation {
                    items.removeAll { $0.id == item.id }
                    Haptics.shared.selectionRemoved()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 1))
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        if items.contains(where: {
            $0.text.localizedCaseInsensitiveCompare(newOptionText)
                == .orderedSame
        }) {
            newOptionText = ""
            return
        }
        let available = Theme.colorNames.filter {
            !usedSessionColors.contains($0)
        }
        let picked =
            (available.isEmpty ? Theme.colorNames : available).randomElement()
            ?? "denim"
        usedSessionColors.insert(picked)
        let newItem = Item(text: newOptionText, colorName: picked)
        withAnimation(.spring()) { items.insert(newItem, at: 0) }
        newOptionText = ""
        isInputFocused = true
    }
}
