import SwiftUI
import UIKit

struct DeckView: View {
    // 1. PERSISTENCE
    @State var items: [Item] = {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            return decoded
        }
        return [
            Item(text: "Pizza 🍕", colorName: "orange"),
            Item(text: "Sushi 🍣", colorName: "pink"),
            Item(text: "Cinema 🍿", colorName: "purple")
        ]
    }()
    
    @State private var newOptionText: String = ""
    @State private var showInput: Bool = false
    @State private var showList: Bool = false
    @State private var isShuffling: Bool = false
    @Namespace private var animationSpace
    
    @State private var sparkleTrigger: Int = 0
    
    var currentThemeColor: Color {
        items.first?.color ?? .gray
    }
    
    var body: some View {
        // MAIN CONTENT (Cards & Header)
        ZStack {
            // HEADER
            VStack {
                HStack {
                    Button(action: { showList = true }) {
                        Image(systemName: "list.bullet")
                    }
                    .buttonStyle(.orbitGlass)
                    .disabled(isShuffling)
                    .opacity(isShuffling ? 0.5 : 1)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                Spacer()
            }
            .zIndex(10)
            
            // CARD STACK
            ZStack {
                if items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("No options left.\nAdd something!")
                            .font(Orbit.headingFont())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                } else {
                    // SPARKLES
                    SparkleView(trigger: $sparkleTrigger)
                        .zIndex(-1)
                    
                    ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, item in
                        CardView(text: item.text, color: item.color)
                            .rotationEffect(.degrees(item.rotation))
                            .offset(y: CGFloat(index) * 8)
                            .scaleEffect(1.0 - (CGFloat(index) * 0.03))
                            .zIndex(Double(items.count - index))
                            .blur(radius: isShuffling ? 10 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isShuffling)
                    }
                }
            }
            // Add padding to bottom so cards don't touch the buttons
            .padding(.bottom, 20)
            .animation(isShuffling ? .linear(duration: 0.1) : Orbit.gravity, value: items.map { $0.id })
            
        }
        // FIX: WE MOVE THE CONTROLS OUT OF THE ZSTACK
        // .safeAreaInset automatically handles the Keyboard overlap for us.
        .safeAreaInset(edge: .bottom) {
            VStack {
                if showInput {
                    ControlBar(
                        text: $newOptionText,
                        onAdd: addOption,
                        onShuffle: spinDeck
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)
                    
                } else {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation(Orbit.morph) { showInput = true }
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.orbitGlass)
                        .disabled(isShuffling)
                        
                        ZStack {
                            if isShuffling {
                                Circle()
                                    .fill(Color.white)
                                    .matchedGeometryEffect(id: "Shape", in: animationSpace)
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        ProgressView()
                                            .tint(.black)
                                            .transition(.scale.combined(with: .opacity))
                                    )
                            } else {
                                Button(action: spinDeck) {
                                    HStack {
                                        Image(systemName: "shuffle")
                                        Text("Shuffle")
                                    }
                                    .font(Orbit.headingFont())
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 30)
                                    .frame(height: 56)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                            .matchedGeometryEffect(id: "Shape", in: animationSpace)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(items.isEmpty)
                                .opacity(items.isEmpty ? 0.5 : 1)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.top, 10) // Small breathing room above buttons
            // This background ensures the bar is readable if it overlaps content
            .background(Color.clear)
        }
        // BACKGROUND GRADIENT (Stays continuously behind everything)
        .background(
            LinearGradient(
                colors: [currentThemeColor.opacity(0.6), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        // ACTIONS
        .sheet(isPresented: $showList) {
            OptionsListView(items: $items)
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: items) { oldValue, newValue in
            saveItems()
        }
        .onShake {
            spinDeck()
        }
        // Ensure tapping background dismisses keyboard
        .onTapGesture {
            withAnimation(Orbit.morph) { showInput = false }
            hideKeyboard()
        }
    }
    
    // --- HELPERS ---
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "savedItems")
        }
    }
    
    // --- ACTIONS ---
    
    func spinDeck() {
        guard !items.isEmpty && !isShuffling else { return }
        
        let originalTopId = items.first?.id
        
        withAnimation(Orbit.morph) { isShuffling = true }
        Haptics.shared.play(.medium)
        
        let shuffleCount = 8
        let speed = 0.1
        
        for i in 0..<shuffleCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * speed)) {
                Haptics.shared.play(.light)
                if let first = items.first {
                    var newItems = items
                    newItems.removeFirst()
                    newItems.append(first)
                    items = newItems
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(shuffleCount) * speed)) {
            Haptics.shared.play(.heavy)
            
            let candidates = items.filter { $0.id != originalTopId }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if let winner = candidates.randomElement() {
                    var remaining = items.filter { $0.id != winner.id }
                    remaining.shuffle()
                    items = [winner] + remaining
                } else {
                    items.shuffle()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sparkleTrigger += 1
            }
            
            withAnimation(.easeOut(duration: 0.3)) {
                isShuffling = false
            }
        }
    }
    
    func addOption() {
        guard !newOptionText.isEmpty else { return }
        Haptics.shared.play(.heavy)
        let newItem = Item(text: newOptionText, colorName: Theme.randomColorName())
        
        withAnimation(Orbit.gravity) {
            items.insert(newItem, at: 0)
            showInput = false
        }
        newOptionText = ""
        hideKeyboard()
    }
}

// --- SPARKLE COMPONENT ---
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
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 20, height: 20)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .blur(radius: 4)
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            fire()
        }
    }
    
    func fire() {
        particles = []
        let colors: [Color] = [.cyan, .yellow, .green, .mint, .orange, .pink, .purple]
        
        for _ in 0..<45 {
            let color = colors.randomElement() ?? .cyan
            let angle = Double.random(in: 0...2 * .pi)
            let startRadius: CGFloat = 170
            let startX = cos(angle) * startRadius
            let startY = sin(angle) * startRadius
            
            particles.append(Particle(x: startX, y: startY, color: color, scale: 0.5, opacity: 1))
        }
        
        for i in indices.indices {
            let angle = atan2(particles[i].y, particles[i].x)
            let endRadius = CGFloat.random(in: 350...550)
            
            withAnimation(.easeOut(duration: 0.7)) {
                particles[i].x = cos(angle) * endRadius
                particles[i].y = sin(angle) * endRadius
                particles[i].scale = 1.2
                particles[i].opacity = 0
            }
        }
    }
    
    var indices: Range<Int> { 0..<particles.count }
}

#Preview {
    DeckView()
}
