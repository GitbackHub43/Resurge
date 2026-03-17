import SwiftUI

struct AddHabitOnboardingView: View {

    @Binding var habitName: String
    @Binding var selectedProgramType: ProgramType
    @Binding var startDate: Date
    @Binding var dailyUnits: Double

    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Text("What are you quitting?")
                        .font(Typography.largeTitle)
                        .rainbowText()
                        .multilineTextAlignment(.center)

                    Text("Choose the habit you want to overcome.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Program type list — thin rows, text left, animation right
                VStack(spacing: 8) {
                    ForEach(ProgramType.allCases) { program in
                        programRow(program)
                    }
                }
                .padding(.horizontal, AppStyle.screenPadding)

                Spacer().frame(height: AppStyle.largeSpacing)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onChange(of: selectedProgramType) { newValue in
            habitName = "Quit \(newValue.displayName)"
        }
    }

    // MARK: - Thin Program Row

    @ViewBuilder
    private func programRow(_ program: ProgramType) -> some View {
        let isSelected = selectedProgramType == program
        let color = Color(hex: program.colorHex)

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedProgramType = program
            }
        } label: {
            HStack(spacing: 0) {
                // Left: radio + text
                HStack(spacing: 12) {
                    // Radio dot
                    ZStack {
                        Circle()
                            .stroke(isSelected ? color : Color.cardBorder, lineWidth: 2)
                            .frame(width: 20, height: 20)

                        if isSelected {
                            Circle()
                                .fill(color)
                                .frame(width: 10, height: 10)
                        }
                    }

                    Text(program.displayName)
                        .font(Typography.headline)
                        .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                }

                Spacer()

                // Right: animated illustration
                ZStack {
                    illustrationView(for: program, isSelected: isSelected)
                }
                .frame(width: 70, height: 50)
                .clipped()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? color.opacity(0.08) : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color.opacity(0.6) : Color.cardBorder.opacity(0.5), lineWidth: isSelected ? 1.5 : 0.5)
            )
            .shadow(color: isSelected ? color.opacity(0.2) : .clear, radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Illustration per Program

    @ViewBuilder
    private func illustrationView(for program: ProgramType, isSelected: Bool) -> some View {
        let color = Color(hex: program.colorHex)

        // Use vivid, realistic glow colors per program instead of generic program color
        let glowColor: Color = {
            switch program {
            case .smoking: return Color(hex: "FF4500")       // red-orange ember
            case .alcohol: return Color(hex: "722F37")       // deep wine red
            case .porn: return Color(hex: "E91E63")          // pink
            case .phone: return Color(hex: "00BCD4")         // cyan
            case .socialMedia: return Color(hex: "9B59B6")   // purple
            case .gaming: return Color(hex: "2ECC71")        // green
            case .sugar: return Color(hex: "FF9800")         // orange
            case .emotionalEating: return Color(hex: "8D6E63") // warm brown
            case .shopping: return Color(hex: "1ABC9C")      // teal
            case .gambling: return Color(hex: "D4AC0D")      // gold
            }
        }()

        ZStack {
            // Colored glow background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(isSelected ? 0.3 : 0.1), .clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)

            // The actual illustration
            illustrationContent(for: program, isSelected: isSelected, color: color)
        }
    }

    @ViewBuilder
    private func illustrationContent(for program: ProgramType, isSelected: Bool, color: Color) -> some View {
        switch program {
        case .smoking:
            SmokingIllustration(isActive: isSelected, color: color)
        case .alcohol:
            AlcoholIllustration(isActive: isSelected, color: color)
        case .porn:
            ShieldIllustration(isActive: isSelected, color: color)
        case .phone:
            PhoneIllustration(isActive: isSelected, color: color)
        case .socialMedia:
            SocialMediaIllustration(isActive: isSelected, color: color)
        case .gaming:
            GamingIllustration(isActive: isSelected, color: color)
        case .sugar:
            SugarIllustration(isActive: isSelected, color: color)
        case .emotionalEating:
            EatingIllustration(isActive: isSelected, color: color)
        case .shopping:
            ShoppingIllustration(isActive: isSelected, color: color)
        case .gambling:
            DiceIllustration(isActive: isSelected, color: color)
        }
    }
}

// MARK: - Continuous Animation Helper
// Uses a timer to drive phase-based animations that never stall

struct LoopingAnimation: View {
    let isActive: Bool
    let interval: Double
    let content: (CGFloat) -> AnyView

    @State private var phase: CGFloat = 0

    var body: some View {
        content(isActive ? phase : 0)
            .onAppear { startTimer() }
            .onChange(of: isActive) { _ in startTimer() }
    }

    private func startTimer() {
        guard isActive else { return }
        // Reset and continuously advance phase
        phase = 0
        withAnimation(.linear(duration: interval).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }
}

// MARK: - Smoking: Cigarette with smoke wisps

struct SmokingIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var phase: CGFloat = 0

    private let emberColor = Color(hex: "FF4500")

    var body: some View {
        ZStack {
            // Cigarette body
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "D4A574"))
                    .frame(width: 10, height: 6)
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 24, height: 5)
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? emberColor : Color.gray.opacity(0.4))
                    .frame(width: 4, height: 5)
                    .shadow(color: isActive ? Color(hex: "FF2200").opacity(0.9) : .clear, radius: 5)
                    .shadow(color: isActive ? emberColor.opacity(0.6) : .clear, radius: 10, x: 0, y: 0)
            }

            if isActive {
                // Smoke wisp 1
                Circle().fill(Color.white.opacity(0.5)).frame(width: 4, height: 4)
                    .offset(x: 20, y: -2 - phase * 20)
                    .opacity(0.6 * (1 - phase))
                    .blur(radius: 1 + phase * 3)

                // Smoke wisp 2 (offset phase)
                Circle().fill(Color.white.opacity(0.4)).frame(width: 3, height: 3)
                    .offset(x: 24, y: -phase2 * 18)
                    .opacity(0.5 * (1 - phase2))
                    .blur(radius: 0.5 + phase2 * 3)

                // Smoke wisp 3
                Circle().fill(Color.white.opacity(0.45)).frame(width: 5, height: 5)
                    .offset(x: 17, y: -4 - phase3 * 20)
                    .opacity(0.5 * (1 - phase3))
                    .blur(radius: 1 + phase3 * 4)
            }
        }
        .onAppear { if isActive { startLoop() } }
        .onChange(of: isActive) { active in
            if active { startLoop() } else { phase = 0 }
        }
    }

    private var phase2: CGFloat { (phase + 0.33).truncatingRemainder(dividingBy: 1.0) }
    private var phase3: CGFloat { (phase + 0.66).truncatingRemainder(dividingBy: 1.0) }

    private func startLoop() {
        phase = 0
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) { phase = 1 }
    }
}

// MARK: - Alcohol: Bottle pouring into glass

struct AlcoholIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var pourPhase: CGFloat = 0
    @State private var fillHeight: CGFloat = 0

    private let wineColor = Color(hex: "722F37")
    private let wineLight = Color(hex: "9B4D5A")

    var body: some View {
        ZStack {
            // Glass outline
            VStack(spacing: 0) {
                // Glass bowl (trapezoid-ish)
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isActive ? Color.white.opacity(0.4) : Color.gray.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 20, height: 18)

                    // Liquid filling up — deep wine red
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isActive ? wineColor.opacity(0.85) : Color.gray.opacity(0.15))
                        .frame(width: 17, height: isActive ? fillHeight : 4)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: fillHeight)
                        .shadow(color: isActive ? wineColor.opacity(0.6) : .clear, radius: 4, x: 0, y: 0)
                }
                // Stem — crystal clear
                Rectangle()
                    .fill(isActive ? Color.white.opacity(0.25) : Color.gray.opacity(0.15))
                    .frame(width: 3, height: 8)
                // Base
                Capsule()
                    .fill(isActive ? Color.white.opacity(0.25) : Color.gray.opacity(0.15))
                    .frame(width: 14, height: 3)
            }

            // Pour stream from top-right
            if isActive {
                // Tilted bottle
                RoundedRectangle(cornerRadius: 2)
                    .fill(wineColor.opacity(0.5))
                    .frame(width: 8, height: 16)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 18, y: -16)

                // Pour stream
                Rectangle()
                    .fill(wineColor.opacity(pourPhase > 0.2 && pourPhase < 0.8 ? 0.7 : 0))
                    .frame(width: 2, height: 12)
                    .offset(x: 10, y: -6)

                // Splash droplets — lighter wine pink
                Circle().fill(wineLight.opacity(0.6)).frame(width: 2, height: 2)
                    .offset(x: 6, y: -2 + pourPhase * 4)
                    .opacity(pourPhase > 0.3 ? 0.7 : 0)

                Circle().fill(wineLight.opacity(0.5)).frame(width: 2, height: 2)
                    .offset(x: -4, y: -1 + pourPhase * 3)
                    .opacity(pourPhase > 0.5 ? 0.6 : 0)
            }
        }
        .onAppear { if isActive { startPour() } }
        .onChange(of: isActive) { active in
            if active { startPour() } else { pourPhase = 0; fillHeight = 0 }
        }
    }

    private func startPour() {
        pourPhase = 0
        fillHeight = 4
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { pourPhase = 1 }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { fillHeight = 15 }
    }
}

// MARK: - Porn: Shield with pulse

struct ShieldIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var pulseScale: CGFloat = 0.7
    @State private var pulseOpacity: Double = 0.6

    private let shieldBlue = Color(hex: "4169E1")
    private let xRed = Color(hex: "FF3333")

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .stroke(shieldBlue.opacity(0.3), lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
            }

            // Silver edge highlight
            Image(systemName: "shield.fill")
                .font(.system(size: 25))
                .foregroundColor(isActive ? Color.white.opacity(0.15) : .clear)
                .offset(x: 0.5, y: 0.5)

            Image(systemName: "shield.fill")
                .font(.system(size: 24))
                .foregroundColor(isActive ? shieldBlue : Color.gray.opacity(0.3))
                .shadow(color: isActive ? shieldBlue.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? shieldBlue.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            // Bright red X mark
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isActive ? xRed : .white.opacity(0.3))
                .shadow(color: isActive ? xRed.opacity(0.6) : .clear, radius: 3)
                .offset(y: -1)
        }
        .onAppear { if isActive { startPulse() } }
        .onChange(of: isActive) { active in
            if active { startPulse() } else { pulseScale = 0.7; pulseOpacity = 0.6 }
        }
    }

    private func startPulse() {
        pulseScale = 0.7
        pulseOpacity = 0.6
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            pulseScale = 1.3
            pulseOpacity = 0
        }
    }
}

// MARK: - Phone: Phone with thumb scrolling

struct PhoneIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var scrollY: CGFloat = -6
    @State private var glow: Double = 0.1

    private let screenBlue = Color(hex: "4DA6FF")
    private let notifRed = Color(hex: "FF3B30")

    var body: some View {
        ZStack {
            // Phone body — silver/gray metallic
            RoundedRectangle(cornerRadius: 5)
                .stroke(isActive ? Color.white.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 20, height: 32)
                .shadow(color: isActive ? screenBlue.opacity(0.4) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? screenBlue.opacity(0.2) : .clear, radius: 12, x: 0, y: 0)

            // Screen — bright blue glow like a real phone screen
            RoundedRectangle(cornerRadius: 3)
                .fill(isActive ? screenBlue.opacity(glow) : Color.gray.opacity(0.05))
                .frame(width: 16, height: 24)
                .offset(y: -1)

            // Content lines scrolling
            if isActive {
                VStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 1).fill(Color.white.opacity(0.5)).frame(width: 12, height: 2)
                    RoundedRectangle(cornerRadius: 1).fill(Color.white.opacity(0.35)).frame(width: 10, height: 2)
                    RoundedRectangle(cornerRadius: 1).fill(Color.white.opacity(0.5)).frame(width: 12, height: 2)
                    RoundedRectangle(cornerRadius: 1).fill(Color.white.opacity(0.35)).frame(width: 8, height: 2)
                }
                .offset(y: scrollY)
                .mask(
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 16, height: 24)
                        .offset(y: -1)
                )
            }

            // Notification badge — bright red like a real notification dot
            if isActive {
                Circle()
                    .fill(notifRed)
                    .frame(width: 6, height: 6)
                    .offset(x: 10, y: -16)
                    .shadow(color: notifRed.opacity(0.7), radius: 2)
            }
        }
        .onAppear { if isActive { startScroll() } }
        .onChange(of: isActive) { active in
            if active { startScroll() } else { scrollY = -6; glow = 0.1 }
        }
    }

    private func startScroll() {
        scrollY = -6
        glow = 0.1
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { scrollY = 6 }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { glow = 0.25 }
    }
}

// MARK: - Social Media: Heart + like bubbles floating

struct SocialMediaIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var phase: CGFloat = 0

    private let twitterBlue = Color(hex: "1DA1F2")
    private let heartRed = Color(hex: "FF3B5C")
    private let fbBlue = Color(hex: "4267B2")

    var body: some View {
        ZStack {
            // Chat bubble — Twitter blue
            Image(systemName: "bubble.left.fill")
                .font(.system(size: 22))
                .foregroundColor(isActive ? twitterBlue.opacity(0.5) : Color.gray.opacity(0.15))
                .shadow(color: isActive ? twitterBlue.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? twitterBlue.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            if isActive {
                let p1 = phase
                let p2 = (phase + 0.33).truncatingRemainder(dividingBy: 1.0)
                let p3 = (phase + 0.66).truncatingRemainder(dividingBy: 1.0)

                // Heart — Instagram heart red
                Image(systemName: "heart.fill").font(.system(size: 8)).foregroundColor(heartRed)
                    .offset(x: -8, y: -p1 * 22).opacity(Double(1 - p1))
                    .shadow(color: heartRed.opacity(0.5), radius: 2)

                // Thumbs up — Facebook blue
                Image(systemName: "hand.thumbsup.fill").font(.system(size: 7)).foregroundColor(fbBlue)
                    .offset(x: 8, y: 2 - p2 * 20).opacity(Double(1 - p2))
                    .shadow(color: fbBlue.opacity(0.5), radius: 2)

                // Second heart — bright red
                Image(systemName: "heart.fill").font(.system(size: 6)).foregroundColor(heartRed.opacity(0.8))
                    .offset(x: 0, y: -2 - p3 * 22).opacity(Double(1 - p3))
            }
        }
        .onAppear { if isActive { startLoop() } }
        .onChange(of: isActive) { active in
            if active { startLoop() } else { phase = 0 }
        }
    }

    private func startLoop() {
        phase = 0
        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) { phase = 1 }
    }
}

// MARK: - Gaming: Controller with joystick wiggle

struct GamingIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var tilt: Double = -8
    @State private var buttonGlow: Bool = false

    private let controllerGray = Color(hex: "4A4A4A")
    private let btnGreen = Color(hex: "00CC00")
    private let btnRed = Color(hex: "FF2222")
    private let btnBlue = Color(hex: "0066FF")
    private let btnYellow = Color(hex: "FFD700")

    var body: some View {
        ZStack {
            // Controller — dark gray body
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 24))
                .foregroundColor(isActive ? controllerGray : Color.gray.opacity(0.3))
                .rotationEffect(.degrees(isActive ? tilt : 0))
                .shadow(color: isActive ? btnGreen.opacity(0.4) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? btnBlue.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            if isActive {
                // Xbox-style colored button dots: green, red, blue, yellow
                Circle().fill(btnGreen).frame(width: 4, height: 4)
                    .offset(x: 6, y: -3)
                    .opacity(buttonGlow ? 1.0 : 0.4)
                    .shadow(color: btnGreen.opacity(0.7), radius: 3)

                Circle().fill(btnRed).frame(width: 4, height: 4)
                    .offset(x: 10, y: 0)
                    .opacity(buttonGlow ? 0.4 : 1.0)
                    .shadow(color: btnRed.opacity(0.7), radius: 3)

                Circle().fill(btnBlue).frame(width: 3, height: 3)
                    .offset(x: 8, y: -6)
                    .opacity(buttonGlow ? 0.8 : 0.3)
                    .shadow(color: btnBlue.opacity(0.7), radius: 3)

                Circle().fill(btnYellow).frame(width: 3, height: 3)
                    .offset(x: 12, y: -3)
                    .opacity(buttonGlow ? 0.3 : 0.8)
                    .shadow(color: btnYellow.opacity(0.7), radius: 3)
            }
        }
        .onAppear { if isActive { startWiggle() } }
        .onChange(of: isActive) { active in
            if active { startWiggle() } else { tilt = 0; buttonGlow = false }
        }
    }

    private func startWiggle() {
        tilt = -8
        buttonGlow = false
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) { tilt = 8 }
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { buttonGlow = true }
    }
}

// MARK: - Procrastination: Clock with spinning hand

struct ClockIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var rotation: Double = 0

    private let goldColor = Color(hex: "DAA520")
    private let brassColor = Color(hex: "C5973B")

    var body: some View {
        ZStack {
            // Clock body — gold/brass
            Circle()
                .stroke(isActive ? goldColor : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 28, height: 28)
                .shadow(color: isActive ? goldColor.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? goldColor.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            // Hour markers — gold
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(isActive ? goldColor.opacity(0.6) : Color.gray.opacity(0.2))
                    .frame(width: 1, height: 3)
                    .offset(y: -11)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            // Clock hand — dark, thin
            Rectangle()
                .fill(isActive ? Color(hex: "2C2C2C") : Color.gray.opacity(0.3))
                .frame(width: 1.5, height: 10)
                .offset(y: -5)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear { if isActive { startClock() } }
        .onChange(of: isActive) { active in
            if active { startClock() } else { rotation = 0 }
        }
    }

    private func startClock() {
        rotation = 0
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) { rotation = 360 }
    }
}

// MARK: - Sugar: Candy unwrapping with sparkles

struct SugarIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var bounce: CGFloat = 0
    @State private var sparkle: CGFloat = 0
    @State private var donutAngle: Double = 0
    @State private var shakeOffset: CGFloat = -2

    private let cookieBrown = Color(hex: "D2691E")
    private let donutPink = Color(hex: "FF69B4")
    private let milkshakeWhite = Color(hex: "FFF5EE")
    private let chocolateChip = Color(hex: "3E2723")
    private let strawberry = Color(hex: "FF1744")

    var body: some View {
        ZStack {
            // Donut (back, left)
            ZStack {
                Circle()
                    .fill(isActive ? donutPink : Color.gray.opacity(0.3))
                    .frame(width: 16, height: 16)
                Circle()
                    .fill(Color.appBackground)
                    .frame(width: 6, height: 6)
                // Sprinkles
                if isActive {
                    Rectangle().fill(Color.neonCyan).frame(width: 3, height: 1).offset(x: -4, y: -5).rotationEffect(.degrees(30))
                    Rectangle().fill(Color.neonGold).frame(width: 3, height: 1).offset(x: 3, y: -6).rotationEffect(.degrees(-20))
                    Rectangle().fill(Color.neonGreen).frame(width: 2, height: 1).offset(x: 5, y: -3).rotationEffect(.degrees(60))
                }
            }
            .rotationEffect(.degrees(donutAngle))
            .offset(x: -12, y: 2)
            .shadow(color: isActive ? donutPink.opacity(0.4) : .clear, radius: 4, x: 1, y: 2)
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                if isActive {
                    donutAngle += 2  // Continuous slow rotation
                    if donutAngle >= 360 { donutAngle = 0 }
                }
            }

            // Cookie (center)
            ZStack {
                Circle()
                    .fill(isActive ? cookieBrown : Color.gray.opacity(0.25))
                    .frame(width: 18, height: 18)
                // Chocolate chips
                if isActive {
                    Circle().fill(chocolateChip).frame(width: 3, height: 3).offset(x: -3, y: -2)
                    Circle().fill(chocolateChip).frame(width: 2, height: 2).offset(x: 3, y: -4)
                    Circle().fill(chocolateChip).frame(width: 3, height: 3).offset(x: 1, y: 3)
                    Circle().fill(chocolateChip).frame(width: 2, height: 2).offset(x: -4, y: 4)
                }
            }
            .offset(y: bounce)
            .shadow(color: isActive ? cookieBrown.opacity(0.5) : .clear, radius: 5, x: 2, y: 3)

            // Milkshake glass (right)
            VStack(spacing: 0) {
                // Straw
                Rectangle()
                    .fill(isActive ? strawberry : Color.gray.opacity(0.3))
                    .frame(width: 2, height: 8)
                    .offset(x: 2, y: 2)
                // Glass
                RoundedRectangle(cornerRadius: 2)
                    .fill(isActive ? milkshakeWhite.opacity(0.8) : Color.gray.opacity(0.15))
                    .frame(width: 10, height: 14)
                // Whipped cream top
                Capsule()
                    .fill(isActive ? Color.white : Color.gray.opacity(0.2))
                    .frame(width: 12, height: 5)
                    .offset(y: -14)
            }
            .offset(x: 14 + (isActive ? shakeOffset : 0), y: 0)
            .shadow(color: isActive ? milkshakeWhite.opacity(0.3) : .clear, radius: 4, x: 1, y: 2)

            // Sparkles
            if isActive {
                let sp = sparkle
                Image(systemName: "sparkle").font(.system(size: 6)).foregroundColor(.neonGold)
                    .offset(x: -8, y: -12 - sp * 6).opacity(Double(1 - sp))
                Image(systemName: "sparkle").font(.system(size: 5)).foregroundColor(donutPink)
                    .offset(x: 10, y: -10 - sp * 8).opacity(Double(1 - sp))
                Image(systemName: "sparkle").font(.system(size: 7)).foregroundColor(.neonGold)
                    .offset(x: 0, y: -14 - sp * 5).opacity(Double(1 - sp))
            }
        }
        .onAppear { if isActive { startAnimation() } }
        .onChange(of: isActive) { active in
            if active { startAnimation() } else { bounce = 0; sparkle = 0; donutAngle = 0; shakeOffset = 0 }
        }
    }

    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { bounce = -3 }
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { sparkle = 1 }
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { shakeOffset = 2 }
    }
}

// MARK: - Emotional Eating: Heart breaking / healing cycle

struct EatingIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var heartScale: CGFloat = 1.0
    @State private var crumbPhase: CGFloat = 0

    private let vividRed = Color(hex: "FF1744")
    private let silverMetal = Color(hex: "C0C0C0")

    var body: some View {
        ZStack {
            // Pulsing heart — vivid red
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(isActive ? vividRed : Color.gray.opacity(0.3))
                .scaleEffect(isActive ? heartScale : 1.0)
                .shadow(color: isActive ? vividRed.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? vividRed.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            // Fork overlay — silver metallic
            Image(systemName: "fork.knife")
                .font(.system(size: 12))
                .foregroundColor(isActive ? silverMetal : Color.gray.opacity(0.2))
                .shadow(color: isActive ? silverMetal.opacity(0.3) : .clear, radius: 2)

            // Crumb particles falling
            if isActive {
                let p1 = crumbPhase
                let p2 = (crumbPhase + 0.5).truncatingRemainder(dividingBy: 1.0)

                Circle().fill(vividRed.opacity(0.5)).frame(width: 3, height: 3)
                    .offset(x: -8, y: 8 + p1 * 12).opacity(Double(1 - p1))

                Circle().fill(vividRed.opacity(0.4)).frame(width: 2, height: 2)
                    .offset(x: 6, y: 10 + p2 * 10).opacity(Double(1 - p2))
            }
        }
        .onAppear { if isActive { startBeat() } }
        .onChange(of: isActive) { active in
            if active { startBeat() } else { heartScale = 1.0; crumbPhase = 0 }
        }
    }

    private func startBeat() {
        heartScale = 0.9
        crumbPhase = 0
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) { heartScale = 1.15 }
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { crumbPhase = 1 }
    }
}

// MARK: - Shopping: Cart with floating sparkles

struct ShoppingIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var phase: CGFloat = 0

    private let cartSilver = Color(hex: "A8B0B8")
    private let cartBlue = Color(hex: "4DA6FF")
    private let saleGold = Color(hex: "FFD700")

    var body: some View {
        ZStack {
            // Cart — silver metallic with blue accent shadow
            Image(systemName: "cart.fill")
                .font(.system(size: 22))
                .foregroundColor(isActive ? cartSilver : Color.gray.opacity(0.3))
                .shadow(color: isActive ? cartBlue.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? cartBlue.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            if isActive {
                let p1 = phase
                let p2 = (phase + 0.5).truncatingRemainder(dividingBy: 1.0)

                // Sparkles — gold/yellow like sale sparkles
                Image(systemName: "sparkle").font(.system(size: 8)).foregroundColor(saleGold)
                    .offset(x: -6, y: -4 - p1 * 16).opacity(Double(1 - p1))
                    .shadow(color: saleGold.opacity(0.5), radius: 2)

                Image(systemName: "sparkle").font(.system(size: 6)).foregroundColor(saleGold.opacity(0.8))
                    .offset(x: 8, y: -2 - p2 * 14).opacity(Double(1 - p2))
                    .shadow(color: saleGold.opacity(0.4), radius: 2)
            }
        }
        .onAppear { if isActive { startLoop() } }
        .onChange(of: isActive) { active in
            if active { startLoop() } else { phase = 0 }
        }
    }

    private func startLoop() {
        phase = 0
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { phase = 1 }
    }
}

// MARK: - Gambling: Dice with rolling glow

struct DiceIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var roll: Double = -15
    @State private var sparkleOn = false

    private let diceWhite = Color.white
    private let casinoGold = Color(hex: "FFD700")
    private let casinoGreen = Color(hex: "00875A")

    var body: some View {
        ZStack {
            // Dice — white with realistic look
            Image(systemName: "dice.fill")
                .font(.system(size: 24))
                .foregroundColor(isActive ? diceWhite.opacity(0.9) : Color.gray.opacity(0.3))
                .rotationEffect(.degrees(isActive ? roll : 0))
                .shadow(color: isActive ? casinoGold.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? casinoGreen.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            if isActive {
                // Casino sparkles — gold and green
                Image(systemName: "sparkle").font(.system(size: 8)).foregroundColor(casinoGold)
                    .offset(x: 14, y: -10).opacity(sparkleOn ? 0.3 : 0.9)
                    .shadow(color: casinoGold.opacity(0.5), radius: 2)

                Image(systemName: "sparkle").font(.system(size: 6)).foregroundColor(casinoGreen)
                    .offset(x: -12, y: -8).opacity(sparkleOn ? 0.9 : 0.3)
                    .shadow(color: casinoGreen.opacity(0.5), radius: 2)
            }
        }
        .onAppear { if isActive { startRoll() } }
        .onChange(of: isActive) { active in
            if active { startRoll() } else { roll = 0; sparkleOn = false }
        }
    }

    private func startRoll() {
        roll = -15
        sparkleOn = false
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { roll = 15 }
        withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) { sparkleOn = true }
    }
}

// MARK: - Sleep: Moon with floating Zzz

struct SleepIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var phase: CGFloat = 0

    private let moonGold = Color(hex: "FFD700")
    private let dreamyBlue = Color(hex: "7B9CFF")
    private let dreamyPurple = Color(hex: "B08CFF")

    var body: some View {
        ZStack {
            // Moon — golden yellow
            Image(systemName: "moon.fill")
                .font(.system(size: 22))
                .foregroundColor(isActive ? moonGold : Color.gray.opacity(0.3))
                .shadow(color: isActive ? moonGold.opacity(0.5) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? moonGold.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)

            if isActive {
                let p1 = phase
                let p2 = (phase + 0.33).truncatingRemainder(dividingBy: 1.0)
                let p3 = (phase + 0.66).truncatingRemainder(dividingBy: 1.0)

                // Z letters — soft blue/purple dreamy colors
                Text("z").font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(dreamyBlue.opacity(0.8))
                    .offset(x: 10, y: -4 - p1 * 16).opacity(Double(1 - p1))

                Text("z").font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(dreamyPurple.opacity(0.7))
                    .offset(x: 16, y: -2 - p2 * 14).opacity(Double(1 - p2))

                Text("Z").font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(dreamyBlue.opacity(0.7))
                    .offset(x: 6, y: -6 - p3 * 18).opacity(Double(1 - p3))
            }
        }
        .onAppear { if isActive { startLoop() } }
        .onChange(of: isActive) { active in
            if active { startLoop() } else { phase = 0 }
        }
    }

    private func startLoop() {
        phase = 0
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) { phase = 1 }
    }
}

// MARK: - Custom: Star with glow

struct StarIllustration: View {
    let isActive: Bool
    let color: Color
    @State private var glowScale: CGFloat = 1.0

    private let starGold = Color(hex: "FFD700")

    var body: some View {
        ZStack {
            // White glow behind star
            if isActive {
                Image(systemName: "star.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.white.opacity(0.2))
                    .scaleEffect(glowScale)
                    .blur(radius: 2)
            }

            // Star — bright gold
            Image(systemName: "star.fill")
                .font(.system(size: 22))
                .foregroundColor(isActive ? starGold : Color.gray.opacity(0.3))
                .shadow(color: isActive ? starGold.opacity(0.6) : .clear, radius: 6, x: 2, y: 3)
                .shadow(color: isActive ? Color.white.opacity(0.3) : .clear, radius: 12, x: 0, y: 0)
        }
        .onAppear { if isActive { startGlow() } }
        .onChange(of: isActive) { active in
            if active { startGlow() } else { glowScale = 1.0 }
        }
    }

    private func startGlow() {
        glowScale = 0.9
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { glowScale = 1.2 }
    }
}

// MARK: - Preview

struct AddHabitOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitOnboardingView(
            habitName: .constant(""),
            selectedProgramType: .constant(.smoking),
            startDate: .constant(Date()),
            dailyUnits: .constant(10),
            onNext: {}
        )
        .preferredColorScheme(.dark)
    }
}
