import SwiftUI

struct DeckView: View {
    @State var items: [Item] = {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            return decoded
        }
        return [Item(text: "Non", colorName: "terracotta"), Item(text: "Oui", colorName: "denim")]
    }()
    
    @State private var newOptionText = ""
    @State private var showInput = false
    @State private var showList = false
    @State private var isShuffling = false
    @State private var sparkleTrigger = 0
    @State private var isKeyboardVisible = false
    @State private var usedSessionColors: Set<String> = []
    
    @State private var dragOffset: CGSize = .zero
    @State private var activeShuffleId: UUID? = nil
    @State private var cardOffsets: [UUID: CGFloat] = [:]
    
    @State private var isHolding = false
    @State private var isTapping = false
    @State private var originalTopId: UUID? = nil
    @State private var lastPressTime: Date = Date()
    @State private var shuffleTask: Task<Void, Never>? = nil
    
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            backgroundLayer
            cardLayer
                .ignoresSafeArea()
                .offset(y: -20)
            headerLayer
            controlLayer
        }
        .sheet(isPresented: $showList) {
            OptionsListView(items: $items)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in isKeyboardVisible = true }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in isKeyboardVisible = false }
        .onChange(of: items) { _, _ in saveItems() }
        .onShake { performShortShuffle() }
    }
    
    // --- LAYERS ---

    private var backgroundLayer: some View {
        LinearGradient(
            colors: [
                items.last?.color.opacity(0.35) ?? .gray.opacity(0.1),
                Color(red: 0.05, green: 0.06, blue: 0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: items.last?.id)
        .onTapGesture { if showInput { isInputFocused = false; hideKeyboard(); withAnimation { showInput = false } } }
    }

    private var cardLayer: some View {
        ZStack {
            if items.isEmpty {
                emptyStateView
            } else {
                SparkleView(trigger: $sparkleTrigger).zIndex(-10)
                
                ForEach(items) { item in
                    CardView(text: item.text, color: item.color)
                        .rotationEffect(getRotation(for: item))
                        .offset(getOffset(for: item))
                        .scaleEffect(getScale(for: item))
                        .blur(radius: isShuffling ? 6 : 0)
                        .zIndex(item.id == activeShuffleId ? 1000 : Double(items.firstIndex(where: { $0.id == item.id }) ?? 0))
                        .gesture(item.id == items.last?.id && !isShuffling ? dragGesture : nil)
                }
            }
        }
        .scaleEffect(isKeyboardVisible ? 0.7 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isKeyboardVisible)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: items.map { $0.id })
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up.slash").font(.system(size: 60)).foregroundStyle(.white.opacity(0.4))
            Text("No options left.").font(Orbit.headingFont()).foregroundStyle(.white.opacity(0.4))
        }
    }

    // --- GEOMETRY ---

    func getOffset(for item: Item) -> CGSize {
        var x = cardOffsets[item.id] ?? 0
        var y: CGFloat = 0
        if item.id == items.last?.id && !isShuffling {
            x += dragOffset.width
            y += dragOffset.height
        }
        return CGSize(width: x, height: y)
    }

    func getRotation(for item: Item) -> Angle {
        var rot = item.rotation
        if item.id == items.last?.id && !isShuffling {
            rot += Double(dragOffset.width / 15)
        }
        if let x = cardOffsets[item.id] {
            rot += Double(x / 18)
        }
        return .degrees(rot)
    }

    func getScale(for item: Item) -> CGFloat {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return 1.0 }
        let distanceToTop = items.count - 1 - index
        let baseScale = 1.0 - (CGFloat(distanceToTop) * 0.03)
        if item.id == items.last?.id && dragOffset != .zero && !isShuffling { return baseScale + 0.02 }
        return baseScale
    }

    // --- SHUFFLE LOGIC ---

    func startContinuousShuffle() {
        guard !items.isEmpty && !isShuffling else { return }
        originalTopId = items.last?.id
        
        withAnimation(.interactiveSpring()) { dragOffset = .zero }
        withAnimation(.easeInOut(duration: 0.2)) { isShuffling = true }
        
        // REFACTORED: Use centralized haptic call
        Haptics.shared.shuffleStart()

        shuffleTask = Task { @MainActor in
            while !Task.isCancelled {
                guard let topItem = items.last else { break }
                let idToMove = topItem.id
                
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    activeShuffleId = idToMove
                    cardOffsets[idToMove] = 450
                }
                
                try? await Task.sleep(nanoseconds: 120_000_000)
                
                // REFACTORED: Use centralized haptic call
                Haptics.shared.shuffleTuck()
                
                if let index = items.firstIndex(where: { $0.id == idToMove }) {
                    let card = items.remove(at: index)
                    items.insert(card, at: 0)
                }
                
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    cardOffsets[idToMove] = 0
                }
                
                try? await Task.sleep(nanoseconds: 150_000_000)
                activeShuffleId = nil
            }
        }
    }

    func endContinuousShuffle() {
        guard isShuffling else { return }
        shuffleTask?.cancel()
        shuffleTask = nil
        
        // REFACTORED: Use centralized haptic call
        Haptics.shared.shuffleSuccess()

        let candidates = items.filter { $0.id != originalTopId }
        let winner = (candidates.randomElement() ?? items.randomElement())!
        var remaining = items.filter { $0.id != winner.id }; remaining.shuffle()
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            items = remaining + [winner]
            isShuffling = false
            isTapping = false
            cardOffsets.removeAll()
            activeShuffleId = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { sparkleTrigger += 1 }
    }

    // --- MANUAL GESTURE ---

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) { dragOffset = value.translation }
            }
            .onEnded { value in
                let threshold: CGFloat = 140
                if abs(value.translation.width) > threshold {
                    let direction: CGFloat = value.translation.width > 0 ? 1 : -1
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        dragOffset.width = 1000 * direction
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Manual card cycle still uses light feedback
                        Haptics.shared.play(.light)
                        let card = items.removeLast()
                        items.insert(card, at: 0)
                        dragOffset = .zero
                    }
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { dragOffset = .zero }
                }
            }
    }

    // --- UI COMPONENTS ---
    
    private var controlLayer: some View {
        VStack {
            Spacer()
            if showInput {
                ControlBar(text: $newOptionText, focusState: $isInputFocused, onAdd: addOption, onShuffle: performShortShuffle)
                    .padding(.bottom, 10).padding(.horizontal, 16).transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 16) {
                    Button(action: { withAnimation { usedSessionColors.removeAll(); showInput = true; isInputFocused = true } }) { Image(systemName: "plus") }
                        .buttonStyle(.orbitGlass)
                    
                    ZStack {
                        Circle().fill(.white).frame(width: 56, height: 56).overlay(ProgressView().tint(.black))
                            .opacity(isTapping ? 1 : 0).scaleEffect(isTapping ? 1 : 0.7)
                        
                        HStack { Image(systemName: "shuffle"); Text("Shuffle") }
                            .font(Orbit.headingFont()).foregroundStyle(.black)
                            .padding(.horizontal, 30).frame(height: 56).background(Capsule().fill(.white))
                            .opacity(isTapping ? 0 : 1).scaleEffect(isTapping ? 0.8 : 1)
                    }
                    .scaleEffect(isHolding ? 1.1 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isTapping)
                    .animation(Orbit.touch, value: isHolding)
                    .contentShape(Capsule())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isShuffling {
                                    lastPressTime = Date()
                                    withAnimation(Orbit.touch) { isHolding = true }
                                    startContinuousShuffle()
                                }
                            }
                            .onEnded { _ in
                                withAnimation(Orbit.touch) { isHolding = false }
                                if Date().timeIntervalSince(lastPressTime) < 0.2 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isTapping = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { endContinuousShuffle() }
                                } else { endContinuousShuffle() }
                            }
                    )
                    .disabled(items.isEmpty)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private var headerLayer: some View {
        VStack {
            HStack {
                Button(action: { showList = true }) { Image(systemName: "list.bullet") }
                    .buttonStyle(.orbitGlass)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
    }

    func performShortShuffle() {
        if !isShuffling {
            withAnimation { isTapping = true }
            startContinuousShuffle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { endContinuousShuffle() }
        }
    }

    func addOption() {
        guard !newOptionText.isEmpty else { return }
        if items.contains(where: { $0.text.lowercased() == newOptionText.lowercased() }) { newOptionText = ""; return }
        let available = Theme.colorNames.filter { !usedSessionColors.contains($0) }
        let picked = (available.isEmpty ? Theme.colorNames : available).randomElement() ?? "denim"
        usedSessionColors.insert(picked)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.append(Item(text: newOptionText, colorName: picked))
        }
        newOptionText = ""; isInputFocused = true
    }
    
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    func saveItems() { if let data = try? JSONEncoder().encode(items) { UserDefaults.standard.set(data, forKey: "savedItems") } }
}

#Preview {
    DeckView()
}
