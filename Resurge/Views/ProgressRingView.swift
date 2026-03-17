import SwiftUI

struct ProgressRingView<Content: View>: View {

    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let content: () -> Content

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = AppStyle.progressRingLineWidth,
        size: CGFloat = AppStyle.progressRingSize,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.content = content
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.neonPurple.opacity(0.1), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)

            // Glow layer (behind progress arc)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)
                .opacity(0.4)

            // Progress arc — rainbow gradient
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center content
            content()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = min(max(newValue, 0), 1)
            }
        }
    }
}

extension ProgressRingView where Content == EmptyView {
    init(
        progress: Double,
        lineWidth: CGFloat = AppStyle.progressRingLineWidth,
        size: CGFloat = AppStyle.progressRingSize
    ) {
        self.init(progress: progress, lineWidth: lineWidth, size: size) {
            EmptyView()
        }
    }
}

struct ProgressRingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            ProgressRingView(progress: 0.65) {
                VStack(spacing: 2) {
                    Text("65%")
                        .font(Typography.statValue)
                        .foregroundColor(.textPrimary)
                    Text("complete")
                        .font(Typography.statLabel)
                        .foregroundColor(.textSecondary)
                }
            }

            ProgressRingView(progress: 0.3, lineWidth: 8, size: 80) {
                Text("9")
                    .font(Typography.statValue)
                    .foregroundColor(.neonCyan)
            }
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
