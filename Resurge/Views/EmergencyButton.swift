import SwiftUI

struct EmergencyButton: View {
    @AppStorage("emergencyButtonEnabled") private var emergencyButtonEnabled = true
    @State private var showEmergencyMode = false
    @State private var isPulsing = false

    var body: some View {
        if emergencyButtonEnabled {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        HapticManager.tap()
                        showEmergencyMode = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.neonOrange, .neonMagenta, .neonPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(
                                    color: Color.neonMagenta.opacity(0.6),
                                    radius: isPulsing ? 16 : 10,
                                    x: 0,
                                    y: 4
                                )
                                .scaleEffect(isPulsing ? 1.05 : 1.0)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 90)
                    .padding(.trailing, 20)
                }
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
            .fullScreenCover(isPresented: $showEmergencyMode) {
                EmergencyModeView()
            }
        }
    }
}

struct EmergencyButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            EmergencyButton()
        }
        .preferredColorScheme(.dark)
    }
}
