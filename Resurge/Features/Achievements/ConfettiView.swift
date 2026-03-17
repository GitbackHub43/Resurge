import SwiftUI

struct ConfettiView: View {
    @State private var isActive = true

    private let particleCount = 60
    private let colors: [Color] = [
        .neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold, .neonGreen
    ]

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                ConfettiParticle(
                    color: colors[index % colors.count],
                    isActive: isActive
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
    }
}

// MARK: - Confetti Particle

private struct ConfettiParticle: View {
    let color: Color
    let isActive: Bool

    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = -100
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 1.0

    private let size: CGFloat = CGFloat.random(in: 6...12)
    private let shape: Int = Int.random(in: 0...2)

    var body: some View {
        Group {
            switch shape {
            case 0:
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
            case 1:
                Rectangle()
                    .fill(color)
                    .frame(width: size, height: size * 0.6)
            default:
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: size * 1.2, height: size * 0.5)
            }
        }
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .offset(x: xOffset, y: yOffset)
        .opacity(isActive ? opacity : 0)
        .onAppear {
            let startX = CGFloat.random(in: -200...200)
            let endX = startX + CGFloat.random(in: -80...80)
            let duration = Double.random(in: 1.5...3.0)
            let delay = Double.random(in: 0...0.6)

            xOffset = startX
            yOffset = -50

            withAnimation(
                .easeOut(duration: duration)
                .delay(delay)
            ) {
                xOffset = endX
                yOffset = UIScreen.main.bounds.height + 50
                rotation = Double.random(in: 360...1080)
            }

            withAnimation(
                .easeIn(duration: 0.3)
                .delay(delay)
            ) {
                opacity = 1.0
            }

            withAnimation(
                .easeIn(duration: 0.5)
                .delay(delay + duration - 0.5)
            ) {
                opacity = 0
                scale = 0.3
            }
        }
    }
}

// MARK: - Preview

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            ConfettiView()
        }
    }
}
