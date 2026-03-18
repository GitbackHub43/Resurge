import SwiftUI

struct BackupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var passphrase = ""
    @State private var showExportSheet = false
    @State private var showImportPicker = false
    @State private var exportedData: Data?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.neonCyan)
                    Text("Encrypted Backup")
                        .font(Typography.largeTitle)
                        .rainbowText()
                    Text("Your data is encrypted with AES-256. Only you can access it with your passphrase.")
                        .font(Typography.body)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppStyle.largeSpacing)

                // Passphrase input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Passphrase")
                        .font(Typography.headline)
                        .foregroundColor(.appText)
                    SecureField("Enter a strong passphrase", text: $passphrase)
                        .font(Typography.body)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(AppStyle.smallCornerRadius)
                        .overlay(RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius).stroke(Color.cardBorder, lineWidth: 1))

                    // Strength indicator
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < passphraseStrength ? strengthColor : Color.cardBorder)
                                .frame(height: 4)
                        }
                    }
                    Text(strengthLabel)
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .padding(.horizontal, AppStyle.screenPadding)

                // Export button
                Button {
                    exportBackup()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("Export Backup")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .disabled(passphrase.count < 6 || isProcessing)
                .opacity(passphrase.count < 6 ? 0.5 : 1)
                .padding(.horizontal, AppStyle.screenPadding)

                // Import button
                Button {
                    showImportPicker = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Import Backup")
                    }
                }
                .buttonStyle(SecondaryButtonStyle(color: .neonPurple))
                .disabled(passphrase.count < 6 || isProcessing)
                .padding(.horizontal, AppStyle.screenPadding)

                // Info card
                VStack(alignment: .leading, spacing: 8) {
                    Label("How it works", systemImage: "info.circle.fill")
                        .font(Typography.headline)
                        .foregroundColor(.neonCyan)
                    Text("Export creates an encrypted .looprootbackup file. Import restores from a previously exported file. Both require the same passphrase.")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }
                .neonCard(glow: .neonCyan)
                .padding(.horizontal, AppStyle.screenPadding)
            }
            .padding(.bottom, AppStyle.largeSpacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Backup")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Backup", isPresented: $showAlert) { Button("OK") {} } message: { Text(alertMessage) }
    }

    private var passphraseStrength: Int {
        var s = 0
        if passphrase.count >= 6 { s += 1 }
        if passphrase.count >= 10 { s += 1 }
        if passphrase.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
        if passphrase.rangeOfCharacter(from: .uppercaseLetters) != nil { s += 1 }
        return s
    }

    private var strengthColor: Color {
        switch passphraseStrength {
        case 1: return .neonOrange
        case 2: return .neonGold
        case 3: return .neonCyan
        case 4: return .neonGreen
        default: return .cardBorder
        }
    }

    private var strengthLabel: String {
        switch passphraseStrength {
        case 0: return "Too short (min 6 characters)"
        case 1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Strong"
        default: return ""
        }
    }

    private func exportBackup() {
        isProcessing = true
        do {
            let data = try EncryptedBackupService.exportBackup(context: viewContext, passphrase: passphrase)
            exportedData = data
            // Save to temp file and share
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("LoopRoot_Backup_\(Date().timeIntervalSince1970).looprootbackup")
            try data.write(to: url)
            showExportSheet = true
            alertMessage = "Backup exported successfully!"
            showAlert = true
        } catch {
            alertMessage = "Export failed: \(error.localizedDescription)"
            showAlert = true
        }
        isProcessing = false
    }
}
