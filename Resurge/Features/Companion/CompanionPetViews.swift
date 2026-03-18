import SwiftUI

// MARK: - Pet Type

enum PetType: String, CaseIterable, Identifiable {
    case dog, cat, hamster, owl
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dog: return "Pup"
        case .cat: return "Kitten"
        case .hamster: return "Nibbles"
        case .owl: return "Owlet"
        }
    }
}

// MARK: - Puppy Pet View

struct DogPetView: View {
    let size: CGFloat
    @State private var tailWag: Double = 0
    @State private var blink = false
    @State private var tongue = false
    @State private var bounce: CGFloat = 0

    var body: some View {
        ZStack {
            // Tail — attached to back of body
            Capsule()
                .fill(Color(hex: "D4882B"))
                .frame(width: size * 0.06, height: size * 0.18)
                .rotationEffect(.degrees(-30 + tailWag), anchor: .bottom)
                .offset(x: -size * 0.2, y: -size * 0.02)

            // Body — round puppy body
            Ellipse()
                .fill(LinearGradient(colors: [Color(hex: "F5A623"), Color(hex: "D4882B")], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.5, height: size * 0.38)
                .offset(y: size * 0.08)

            // Front paws
            Circle()
                .fill(Color(hex: "D4882B"))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: -size * 0.12, y: size * 0.25)
            Circle()
                .fill(Color(hex: "D4882B"))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: size * 0.12, y: size * 0.25)

            // Head — big round puppy head
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "FFBF47"), Color(hex: "F5A623")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.48, height: size * 0.48)
                .offset(y: -size * 0.15 + bounce)

            // Floppy ears — higher up on head
            Ellipse()
                .fill(Color(hex: "D4882B"))
                .frame(width: size * 0.14, height: size * 0.2)
                .rotationEffect(.degrees(-20))
                .offset(x: -size * 0.22, y: -size * 0.28 + bounce)
            Ellipse()
                .fill(Color(hex: "D4882B"))
                .frame(width: size * 0.14, height: size * 0.2)
                .rotationEffect(.degrees(20))
                .offset(x: size * 0.22, y: -size * 0.28 + bounce)

            // Eyes
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.13, height: blink ? size * 0.03 : size * 0.13)
                .offset(x: -size * 0.1, y: -size * 0.18 + bounce)
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.13, height: blink ? size * 0.03 : size * 0.13)
                .offset(x: size * 0.1, y: -size * 0.18 + bounce)

            // Pupils
            if !blink {
                Circle()
                    .fill(Color(hex: "3D2B1F"))
                    .frame(width: size * 0.07)
                    .offset(x: -size * 0.1, y: -size * 0.17 + bounce)
                Circle()
                    .fill(Color(hex: "3D2B1F"))
                    .frame(width: size * 0.07)
                    .offset(x: size * 0.1, y: -size * 0.17 + bounce)
                // Eye shine
                Circle().fill(Color.white).frame(width: size * 0.03).offset(x: -size * 0.08, y: -size * 0.19 + bounce)
                Circle().fill(Color.white).frame(width: size * 0.03).offset(x: size * 0.12, y: -size * 0.19 + bounce)
            }

            // Nose
            Ellipse()
                .fill(Color(hex: "3D2B1F"))
                .frame(width: size * 0.08, height: size * 0.06)
                .offset(y: -size * 0.08 + bounce)

            // Tongue (panting)
            if tongue {
                Capsule()
                    .fill(Color(hex: "FF7B9C"))
                    .frame(width: size * 0.06, height: size * 0.08)
                    .offset(x: size * 0.02, y: -size * 0.02 + bounce)
            }
        }
        .frame(width: size, height: size)
        .clipped()
        .contentShape(Rectangle())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) { tailWag = 35 }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounce = -size * 0.02 }
            blinkLoop()
            tongueLoop()
        }
    }

    private func blinkLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2...4)) {
            withAnimation(.easeInOut(duration: 0.08)) { blink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.08)) { blink = false }
                blinkLoop()
            }
        }
    }

    private func tongueLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 3...6)) {
            withAnimation(.easeOut(duration: 0.15)) { tongue = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.15)) { tongue = false }
                tongueLoop()
            }
        }
    }
}

// MARK: - Kitten Pet View

struct CatPetView: View {
    let size: CGFloat
    @State private var tailSway: Double = 0
    @State private var blink = false
    @State private var pawLick = false
    @State private var purr: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Tail — curved, attached to body
            Capsule()
                .fill(Color(hex: "9E9E9E"))
                .frame(width: size * 0.05, height: size * 0.22)
                .rotationEffect(.degrees(-40 + tailSway), anchor: .bottom)
                .offset(x: -size * 0.22, y: -size * 0.0)

            // Body
            Ellipse()
                .fill(LinearGradient(colors: [Color(hex: "B0B0B0"), Color(hex: "8A8A8A")], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.45, height: size * 0.33)
                .scaleEffect(purr)
                .offset(y: size * 0.1)

            // Front paws
            Circle()
                .fill(Color(hex: "C0C0C0"))
                .frame(width: size * 0.09)
                .offset(x: -size * 0.1, y: size * 0.25)
            Circle()
                .fill(Color(hex: "C0C0C0"))
                .frame(width: size * 0.09)
                .offset(x: size * 0.1, y: size * 0.25)

            // Licking paw (raised)
            if pawLick {
                Circle()
                    .fill(Color(hex: "C0C0C0"))
                    .frame(width: size * 0.08)
                    .offset(x: size * 0.15, y: -size * 0.02)
            }

            // Head — big round kitten head
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "C8C8C8"), Color(hex: "A0A0A0")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: size * 0.48, height: size * 0.48)
                .offset(y: -size * 0.14)

            // Pointed ears
            TriangleShape()
                .fill(Color(hex: "A0A0A0"))
                .frame(width: size * 0.14, height: size * 0.14)
                .offset(x: -size * 0.15, y: -size * 0.36)
            TriangleShape()
                .fill(Color(hex: "A0A0A0"))
                .frame(width: size * 0.14, height: size * 0.14)
                .offset(x: size * 0.15, y: -size * 0.36)

            // Inner ears (pink)
            TriangleShape()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: -size * 0.15, y: -size * 0.34)
            TriangleShape()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.15, y: -size * 0.34)

            // Eyes — big green kitten eyes
            Ellipse()
                .fill(Color(hex: "39FF14"))
                .frame(width: size * 0.14, height: blink ? size * 0.03 : size * 0.13)
                .offset(x: -size * 0.1, y: -size * 0.17)
            Ellipse()
                .fill(Color(hex: "39FF14"))
                .frame(width: size * 0.14, height: blink ? size * 0.03 : size * 0.13)
                .offset(x: size * 0.1, y: -size * 0.17)

            // Slit pupils
            if !blink {
                Ellipse()
                    .fill(Color.black)
                    .frame(width: size * 0.04, height: size * 0.1)
                    .offset(x: -size * 0.1, y: -size * 0.17)
                Ellipse()
                    .fill(Color.black)
                    .frame(width: size * 0.04, height: size * 0.1)
                    .offset(x: size * 0.1, y: -size * 0.17)
            }

            // Nose — tiny pink
            TriangleShape()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: size * 0.06, height: size * 0.04)
                .rotationEffect(.degrees(180))
                .offset(y: -size * 0.08)

            // Whiskers — start close to nose, fan outward
            Group {
                // Left whiskers (anchor on right side so they fan left)
                Capsule().fill(Color.white.opacity(0.45)).frame(width: size * 0.14, height: 0.8)
                    .rotationEffect(.degrees(15), anchor: .trailing)
                    .offset(x: -size * 0.1, y: -size * 0.05)
                Capsule().fill(Color.white.opacity(0.45)).frame(width: size * 0.14, height: 0.8)
                    .rotationEffect(.degrees(-10), anchor: .trailing)
                    .offset(x: -size * 0.1, y: -size * 0.03)
                // Right whiskers (anchor on left side so they fan right)
                Capsule().fill(Color.white.opacity(0.45)).frame(width: size * 0.14, height: 0.8)
                    .rotationEffect(.degrees(-15), anchor: .leading)
                    .offset(x: size * 0.1, y: -size * 0.05)
                Capsule().fill(Color.white.opacity(0.45)).frame(width: size * 0.14, height: 0.8)
                    .rotationEffect(.degrees(10), anchor: .leading)
                    .offset(x: size * 0.1, y: -size * 0.03)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { tailSway = 25 }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { purr = 1.03 }
            blinkLoop()
            pawLoop()
        }
    }

    private func blinkLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 2.5...5)) {
            withAnimation(.easeInOut(duration: 0.08)) { blink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.08)) { blink = false }
                blinkLoop()
            }
        }
    }

    private func pawLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 4...8)) {
            withAnimation(.easeOut(duration: 0.2)) { pawLick = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.2)) { pawLick = false }
                pawLoop()
            }
        }
    }
}

// MARK: - Triangle Helper Shape

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Baby Hamster Pet View

struct HamsterPetView: View {
    let size: CGFloat
    @State private var wheelSpin: Double = 0
    @State private var legRun = false
    @State private var blink = false
    @State private var cheeks: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Wheel — behind hamster
            Circle()
                .stroke(Color(hex: "555555"), lineWidth: size * 0.025)
                .frame(width: size * 0.65, height: size * 0.65)
                .offset(y: size * 0.02)

            // Wheel spokes
            ForEach(0..<4, id: \.self) { i in
                Rectangle()
                    .fill(Color(hex: "444444"))
                    .frame(width: size * 0.008, height: size * 0.32)
                    .rotationEffect(.degrees(Double(i) * 45 + wheelSpin))
                    .offset(y: size * 0.02)
            }

            // Body — very round baby hamster
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "FFD699"), Color(hex: "F0C060")], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(y: size * 0.02)

            // White belly
            Ellipse()
                .fill(Color(hex: "FFF8E8"))
                .frame(width: size * 0.28, height: size * 0.22)
                .offset(y: size * 0.1)

            // Tiny running legs
            Capsule()
                .fill(Color(hex: "F0C060"))
                .frame(width: size * 0.06, height: size * 0.08)
                .rotationEffect(.degrees(legRun ? 25 : -25))
                .offset(x: -size * 0.1, y: size * 0.22)
            Capsule()
                .fill(Color(hex: "F0C060"))
                .frame(width: size * 0.06, height: size * 0.08)
                .rotationEffect(.degrees(legRun ? -25 : 25))
                .offset(x: size * 0.1, y: size * 0.22)

            // Round ears
            Circle()
                .fill(Color(hex: "F0C060"))
                .frame(width: size * 0.12)
                .overlay(Circle().fill(Color(hex: "FFB6C1")).frame(width: size * 0.07))
                .offset(x: -size * 0.16, y: -size * 0.16)
            Circle()
                .fill(Color(hex: "F0C060"))
                .frame(width: size * 0.12)
                .overlay(Circle().fill(Color(hex: "FFB6C1")).frame(width: size * 0.07))
                .offset(x: size * 0.16, y: -size * 0.16)

            // Cheeks — puffy pink
            Circle()
                .fill(Color(hex: "FFB6C1").opacity(0.4))
                .frame(width: size * 0.1)
                .scaleEffect(cheeks)
                .offset(x: -size * 0.14, y: size * 0.0)
            Circle()
                .fill(Color(hex: "FFB6C1").opacity(0.4))
                .frame(width: size * 0.1)
                .scaleEffect(cheeks)
                .offset(x: size * 0.14, y: size * 0.0)

            // Eyes
            Circle()
                .fill(Color.black)
                .frame(width: blink ? size * 0.01 : size * 0.06)
                .offset(x: -size * 0.08, y: -size * 0.05)
            Circle()
                .fill(Color.black)
                .frame(width: blink ? size * 0.01 : size * 0.06)
                .offset(x: size * 0.08, y: -size * 0.05)

            // Eye shine
            if !blink {
                Circle().fill(Color.white).frame(width: size * 0.025).offset(x: -size * 0.07, y: -size * 0.06)
                Circle().fill(Color.white).frame(width: size * 0.025).offset(x: size * 0.09, y: -size * 0.06)
            }

            // Nose
            Ellipse()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: size * 0.04, height: size * 0.03)
                .offset(y: size * 0.02)

            // Tiny front paws on wheel
            Circle()
                .fill(Color(hex: "FFD699"))
                .frame(width: size * 0.06)
                .offset(x: -size * 0.08, y: size * 0.15)
            Circle()
                .fill(Color(hex: "FFD699"))
                .frame(width: size * 0.06)
                .offset(x: size * 0.08, y: size * 0.15)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { wheelSpin = 360 }
            withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) { legRun = true }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { cheeks = 1.12 }
            blinkLoop()
        }
    }

    private func blinkLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 1.5...3)) {
            withAnimation(.easeInOut(duration: 0.06)) { blink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.06)) { blink = false }
                blinkLoop()
            }
        }
    }
}

// MARK: - Baby Owl Pet View

struct OwlPetView: View {
    let size: CGFloat
    @State private var headTilt: Double = 0
    @State private var blink = false
    @State private var fluff: CGFloat = 1.0
    @State private var galaxyShift = false

    var body: some View {
        ZStack {
            // Tiny feet
            Circle().fill(Color(hex: "FFD700")).frame(width: size * 0.06).offset(x: -size * 0.06, y: size * 0.28)
            Circle().fill(Color(hex: "FFD700")).frame(width: size * 0.06).offset(x: size * 0.06, y: size * 0.28)

            // Body — round fluffy white baby owl
            Ellipse()
                .fill(LinearGradient(colors: [Color.white, Color(hex: "E8E8F0")], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.45, height: size * 0.38)
                .scaleEffect(fluff)
                .offset(y: size * 0.08)

            // Belly fluff (slightly warm white)
            Ellipse()
                .fill(Color(hex: "F5F0FF"))
                .frame(width: size * 0.3, height: size * 0.22)
                .offset(y: size * 0.1)

            // Little wings tucked in
            Ellipse()
                .fill(Color(hex: "E0E0EA"))
                .frame(width: size * 0.12, height: size * 0.2)
                .rotationEffect(.degrees(-10))
                .offset(x: -size * 0.22, y: size * 0.06)
            Ellipse()
                .fill(Color(hex: "E0E0EA"))
                .frame(width: size * 0.12, height: size * 0.2)
                .rotationEffect(.degrees(10))
                .offset(x: size * 0.22, y: size * 0.06)

            // Head — rotates as one unit
            ZStack {
                // Big round white baby head
                Circle()
                    .fill(LinearGradient(colors: [Color.white, Color(hex: "F0EFF5")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size * 0.52, height: size * 0.52)

                // Fluffy ear tufts
                Circle()
                    .fill(Color(hex: "F0EFF5"))
                    .frame(width: size * 0.1)
                    .offset(x: -size * 0.18, y: -size * 0.23)
                Circle()
                    .fill(Color(hex: "F0EFF5"))
                    .frame(width: size * 0.1)
                    .offset(x: size * 0.18, y: -size * 0.23)

                // Facial disc — soft lavender circles around eyes
                Circle()
                    .fill(Color(hex: "E8E0F0"))
                    .frame(width: size * 0.2)
                    .offset(x: -size * 0.1, y: -size * 0.04)
                Circle()
                    .fill(Color(hex: "E8E0F0"))
                    .frame(width: size * 0.2)
                    .offset(x: size * 0.1, y: -size * 0.04)

                // Galaxy eyes — deep blue space with tiny white stars
                if !blink {
                    // Left eye
                    ZStack {
                        // Deep space blue base
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "0D1B4A"), Color(hex: "0A1030"), Color(hex: "050818")],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: size * 0.08
                                )
                            )
                            .frame(width: size * 0.16)
                        // Tiny stars
                        Circle().fill(Color.white).frame(width: size * 0.015).offset(x: -size * 0.03, y: -size * 0.04)
                        Circle().fill(Color.white).frame(width: size * 0.01).offset(x: size * 0.04, y: -size * 0.02)
                        Circle().fill(Color.white).frame(width: size * 0.012).offset(x: -size * 0.01, y: size * 0.03)
                        Circle().fill(Color.white).frame(width: size * 0.008).offset(x: size * 0.02, y: size * 0.04)
                        Circle().fill(Color.white.opacity(0.7)).frame(width: size * 0.01).offset(x: -size * 0.04, y: size * 0.01)
                        // Subtle blue nebula glow
                        Circle().fill(Color(hex: "1E90FF").opacity(galaxyShift ? 0.3 : 0.1)).frame(width: size * 0.06).offset(x: size * 0.02, y: -size * 0.01)
                        // Black pupil
                        Circle().fill(Color.black).frame(width: size * 0.06)
                        // Eye shine
                        Circle().fill(Color.white).frame(width: size * 0.025).offset(x: -size * 0.02, y: -size * 0.02)
                    }
                    .shadow(color: Color(hex: "1E90FF").opacity(0.4), radius: 3)
                    .offset(x: -size * 0.1, y: -size * 0.04)

                    // Right eye
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "0D1B4A"), Color(hex: "0A1030"), Color(hex: "050818")],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: size * 0.08
                                )
                            )
                            .frame(width: size * 0.16)
                        Circle().fill(Color.white).frame(width: size * 0.012).offset(x: size * 0.03, y: -size * 0.03)
                        Circle().fill(Color.white).frame(width: size * 0.01).offset(x: -size * 0.04, y: size * 0.01)
                        Circle().fill(Color.white).frame(width: size * 0.015).offset(x: size * 0.01, y: size * 0.04)
                        Circle().fill(Color.white).frame(width: size * 0.008).offset(x: -size * 0.02, y: -size * 0.04)
                        Circle().fill(Color.white.opacity(0.7)).frame(width: size * 0.01).offset(x: size * 0.03, y: size * 0.02)
                        Circle().fill(Color(hex: "1E90FF").opacity(galaxyShift ? 0.1 : 0.3)).frame(width: size * 0.05).offset(x: -size * 0.02, y: size * 0.01)
                        Circle().fill(Color.black).frame(width: size * 0.06)
                        Circle().fill(Color.white).frame(width: size * 0.025).offset(x: size * 0.02, y: -size * 0.02)
                    }
                    .shadow(color: Color(hex: "1E90FF").opacity(0.4), radius: 3)
                    .offset(x: size * 0.1, y: -size * 0.04)
                } else {
                    // Closed eyes
                    Capsule().fill(Color(hex: "C0B8D0")).frame(width: size * 0.12, height: size * 0.02).offset(x: -size * 0.1, y: -size * 0.04)
                    Capsule().fill(Color(hex: "C0B8D0")).frame(width: size * 0.12, height: size * 0.02).offset(x: size * 0.1, y: -size * 0.04)
                }

                // Beak — small golden
                TriangleShape()
                    .fill(Color(hex: "FFD700"))
                    .frame(width: size * 0.07, height: size * 0.04)
                    .rotationEffect(.degrees(180))
                    .offset(y: size * 0.06)
            }
            .frame(width: size * 0.55, height: size * 0.55)
            .rotationEffect(.degrees(headTilt))
            .offset(y: -size * 0.12)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { headTilt = 12 }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { fluff = 1.04 }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { galaxyShift = true }
            blinkLoop()
        }
    }

    private func blinkLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .random(in: 3...6)) {
            withAnimation(.easeInOut(duration: 0.1)) { blink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.1)) { blink = false }
                blinkLoop()
            }
        }
    }
}

// MARK: - Pet Preview Screen (Debug)

struct PetPreviewScreen: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Text("Baby Companions")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .padding(.top, 20)

                    // Large previews
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(PetType.allCases) { pet in
                            VStack(spacing: 8) {
                                petView(for: pet, size: 120)
                                    .frame(width: 130, height: 130)
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.cardBorder, lineWidth: 1)
                                    )
                                Text(pet.displayName)
                                    .font(Typography.headline)
                                    .foregroundColor(.appText)
                                Text(pet.rawValue.capitalized)
                                    .font(Typography.caption)
                                    .foregroundColor(.subtleText)
                            }
                        }
                    }
                    .padding(.horizontal, AppStyle.screenPadding)

                    // Corner size preview
                    VStack(spacing: 8) {
                        Text("Corner Size (how they appear in-app)")
                            .font(Typography.caption)
                            .foregroundColor(.subtleText)

                        HStack(spacing: 20) {
                            ForEach(PetType.allCases) { pet in
                                VStack(spacing: 4) {
                                    petView(for: pet, size: 44)
                                        .frame(width: 48, height: 48)
                                    Text(pet.rawValue)
                                        .font(.system(size: 9))
                                        .foregroundColor(.subtleText)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, AppStyle.screenPadding)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Pet Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func petView(for type: PetType, size: CGFloat) -> some View {
        switch type {
        case .dog: DogPetView(size: size)
        case .cat: CatPetView(size: size)
        case .hamster: HamsterPetView(size: size)
        case .owl: OwlPetView(size: size)
        }
    }
}
