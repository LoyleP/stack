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
            
            // Spawn Zone: calibrated to appear outside the card edges
            let startRadius: CGFloat = 170
            let startX = cos(angle) * startRadius
            let startY = sin(angle) * startRadius
            
            particles.append(Particle(x: startX, y: startY, color: color, scale: 0.5, opacity: 1))
        }
        
        for i in particles.indices {
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
}
