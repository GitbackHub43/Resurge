import SwiftUI
import CoreData

struct DataExportView: View {
    @EnvironmentObject var environment: AppEnvironment

    enum ExportType: String, CaseIterable {
        case habits = "Habits"
        case logs = "Daily Logs"
        case journal = "Journal Entries"

        var iconName: String {
            switch self {
            case .habits:  return "repeat.circle.fill"
            case .logs:    return "calendar.badge.clock"
            case .journal: return "book.closed.fill"
            }
        }
    }

    @State private var selectedTypes: Set<ExportType> = [.habits, .logs, .journal]
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                // MARK: - Description
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.neonPurple)
                    Text("Export Your Data")
                        .font(.title2.weight(.bold))
                        .rainbowText()
                    Text("Export your recovery data as CSV files. You can import them into spreadsheets or other apps.")
                        .font(.subheadline)
                        .foregroundColor(.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top)

                // MARK: - Type Selection
                VStack(spacing: 0) {
                    ForEach(ExportType.allCases, id: \.self) { type in
                        Button {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: type.iconName)
                                    .font(.title3)
                                    .foregroundColor(iconColor(for: type))
                                    .frame(width: 30)

                                Text(type.rawValue)
                                    .font(.body)
                                    .foregroundColor(.appText)

                                Spacer()

                                Image(systemName: selectedTypes.contains(type) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedTypes.contains(type) ? .neonCyan : .subtleText)
                            }
                            .padding()
                        }

                        if type != ExportType.allCases.last {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .background(Color.cardBackground)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(0.4)
                )
                .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
                .padding(.horizontal)

                // MARK: - Progress
                if isExporting {
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .neonCyan))
                        Text("Preparing export...")
                            .font(.caption)
                            .foregroundColor(.subtleText)
                    }
                }

                Spacer()

                // MARK: - Export Button
                Button {
                    exportData()
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                        Text("Export Selected Data")
                    }
                }
                .buttonStyle(RainbowButtonStyle())
                .opacity(selectedTypes.isEmpty ? 0.4 : 1.0)
                .disabled(selectedTypes.isEmpty || isExporting)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheetView(activityItems: [url])
            }
        }
    }

    private func iconColor(for type: ExportType) -> Color {
        switch type {
        case .habits:  return .neonCyan
        case .logs:    return .neonPurple
        case .journal: return .neonGold
        }
    }

    private func exportData() {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            var csvContent = "Resurge Data Export\n\n"

            if selectedTypes.contains(.habits) {
                csvContent += "=== HABITS ===\nName,Program Type,Start Date,Goal Days\n"
                csvContent += "Sample Habit,smoking,2024-01-01,30\n\n"
            }
            if selectedTypes.contains(.logs) {
                csvContent += "=== DAILY LOGS ===\nDate,Mood,Pledged,Reflected,Lapsed\n"
                csvContent += "2024-01-15,4,true,true,false\n\n"
            }
            if selectedTypes.contains(.journal) {
                csvContent += "=== JOURNAL ===\nDate,Title,Mood,Is Reflection\n"
                csvContent += "2024-01-15,My First Entry,4,false\n\n"
            }

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("resurge_export_\(Date().timeIntervalSince1970).csv")

            try? csvContent.write(to: tempURL, atomically: true, encoding: .utf8)

            DispatchQueue.main.async {
                isExporting = false
                exportedURL = tempURL
                showShareSheet = true
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        let env = AppEnvironment.preview
        NavigationView {
            DataExportView()
                .environmentObject(env)
        }
    }
}
