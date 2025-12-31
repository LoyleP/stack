import SwiftUI

struct SparkleView: View {
    @Binding var trigger: Int
    @State private var particles: [Particle] = []
    struct Particle: Identifiable { let id = UUID(); var x, y: CGFloat; var color: Color; var scale, opacity: Double }
    
    var body: some View {
        ZStack {
            ForEach(particles) { p in
                Circle().fill(p.color).frame(width: 20, height: 20)
                    .scaleEffect(p.scale).opacity(p.opacity).blur(radius: 4)
                    .offset(x: p.x, y: p.y)
            }
        }
        .allowsHitTesting(false).onChange(of: trigger) { _, _ in fire() }
    }
    
    func fire() {
        particles = []
        let colors: [Color] = [.cyan, .yellow, .mint, .orange, .pink, .purple]
        for _ in 0..<45 {
            let angle = Double.random(in: 0...2 * .pi)
            let start = 170.0
            particles.append(Particle(x: cos(angle) * start, y: sin(angle) * start, color: colors.randomElement()!, scale: 0.5, opacity: 1))
        }
        for i in particles.indices {
            let angle = atan2(particles[i].y, particles[i].x)
            let dist = CGFloat.random(in: 350...550)
            withAnimation(.easeOut(duration: 0.7)) {
                particles[i].x = cos(angle) * dist
                particles[i].y = sin(angle) * dist
                particles[i].scale = 1.2; particles[i].opacity = 0
            }
        }
    }
}
