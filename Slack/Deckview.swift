import SwiftUI

struct DeckView: View {
    @State var items: [Item] = {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            return decoded
        }
        return [Item(text: "Oui", colorName: "blue"), Item(text: "Non", colorName: "red")]
    }()
    
    @State private var newOptionText = ""
    @State private var showInput = false
    @State private var showList = false
    @State private var isShuffling = false
    @State private var sparkleTrigger = 0
    // NEW: Track keyboard state for resizing
    @State private var isKeyboardVisible = false
    @Namespace private var animationSpace

    var body: some View {
        ZStack {
            // LAYER 1: FIXED BACKGROUND
            LinearGradient(colors: [items.first?.color.opacity(0.5) ?? .gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(Orbit.gravity, value: items.first?.id)

            // LAYER 2: CARDS (Fixed center, responsive scaling)
            ZStack {
                if items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.4))
                        Text("No options left.").font(Orbit.headingFont()).foregroundStyle(.white.opacity(0.4))
                    }
                } else {
                    SparkleView(trigger: $sparkleTrigger).zIndex(-1)
                    
                    ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, item in
                        CardView(text: item.text, color: item.color)
                            .rotationEffect(.degrees(item.rotation))
                            .offset(y: CGFloat(index) * 8)
                            .scaleEffect(1.0 - (CGFloat(index) * 0.03))
                            .zIndex(Double(items.count - index))
                            .blur(radius: isShuffling ? 10 : 0)
                    }
                }
            }
            // THE TWEAK: Decrease size by 30% when keyboard is up
            .scaleEffect(isKeyboardVisible ? 0.7 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isKeyboardVisible)
            .ignoresSafeArea(.keyboard)
            .animation(isShuffling ? .linear(duration: 0.1) : Orbit.gravity, value: items.map { $0.id })

            // LAYER 3: PINNED HEADER
            VStack {
                HStack {
                    Button(action: { showList = true }) { Image(systemName: "list.bullet") }
                        .buttonStyle(.orbitGlass)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 8)
                Spacer()
            }
            .ignoresSafeArea(.keyboard)

            // LAYER 4: FLOATING CONTROLS
            VStack {
                Spacer()
                if showInput {
                    ControlBar(text: $newOptionText, onAdd: addOption, onShuffle: spinDeck)
                        .padding(.bottom, 10).padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    interactionButtons
                }
            }
        }
        .sheet(isPresented: $showList) {
            OptionsListView(items: $items)
                .presentationDetents([.fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
        // Listeners for keyboard show/hide to trigger the resize
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onChange(of: items) { _, _ in saveItems() }
        .onShake { spinDeck() }
        .onTapGesture { if showInput { hideKeyboard(); withAnimation { showInput = false } } }
    }

    private var interactionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { withAnimation(Orbit.morph) { showInput = true } }) { Image(systemName: "plus") }
                .buttonStyle(.orbitGlass)
            
            Button(action: spinDeck) {
                HStack {
                    if isShuffling { ProgressView().tint(.black) }
                    else { Image(systemName: "shuffle"); Text("Shuffle") }
                }
                .font(Orbit.headingFont()).foregroundStyle(.black)
                .padding(.horizontal, 30).frame(height: 56)
                .background(Capsule().fill(.white))
            }
            .disabled(items.isEmpty || isShuffling)
        }
        .padding(.bottom, 20)
    }

    func spinDeck() {
        guard !items.isEmpty && !isShuffling else { return }
        let originalId = items.first?.id
        withAnimation(Orbit.morph) { isShuffling = true }
        
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.1)) {
                Haptics.shared.play(.light)
                items.append(items.removeFirst())
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            Haptics.shared.play(.heavy)
            let winner = items.filter { $0.id != originalId }.randomElement() ?? items.randomElement()!
            var remaining = items.filter { $0.id != winner.id }; remaining.shuffle()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { items = [winner] + remaining }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { sparkleTrigger += 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { isShuffling = false } }
        }
    }

    func addOption() {
        if items.contains(where: { $0.text.lowercased() == newOptionText.lowercased() }) {
            newOptionText = ""; return
        }
        let item = Item(text: newOptionText, colorName: Theme.randomColorName())
        withAnimation(Orbit.gravity) { items.insert(item, at: 0); showInput = false }
        newOptionText = ""; hideKeyboard()
    }
    
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    func saveItems() { if let data = try? JSONEncoder().encode(items) { UserDefaults.standard.set(data, forKey: "savedItems") } }
}

import SwiftUI

struct SparkleView: View {
    @Binding var trigger: Int
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var color: Color
        var scale: CGFloat = 1
        var opacity: Double = 1
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: 25, height: 25)
                    .scaleEffect(p.scale)
                    .opacity(p.opacity)
                    .blur(radius: 5)
                    .offset(x: p.x, y: p.y)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            fire()
        }
    }
    
    func fire() {
        particles = []
        let colors: [Color] = [.cyan, .yellow, .mint, .orange, .pink, .purple]
        
        for _ in 0..<45 {
            let color = colors.randomElement() ?? .cyan
            let angle = Double.random(in: 0...2 * .pi)
            let startRadius: CGFloat = 180
            
            particles.append(Particle(
                x: cos(angle) * startRadius,
                y: sin(angle) * startRadius,
                color: color,
                scale: 0.5,
                opacity: 1
            ))
        }
        
        for i in particles.indices {
            let angle = atan2(particles[i].y, particles[i].x)
            let dist = CGFloat.random(in: 350...550)
            
            withAnimation(.easeOut(duration: 0.8)) {
                particles[i].x = cos(angle) * dist
                particles[i].y = sin(angle) * dist
                particles[i].scale = 1.5
                particles[i].opacity = 0
            }
        }
    }
}
