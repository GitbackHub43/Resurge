import SwiftUI

struct ProgramSetupView: View {

    let programType: ProgramType
    @Binding var setupValues: [String: String]
    @Binding var startDate: Date
    let onNext: () -> Void

    @State private var customTextFields: [String: String?] = [:]
    @State private var wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()

    private var template: ProgramTemplate? {
        ProgramTemplates.template(for: programType)
    }

    private var fields: [ProgramSetupField] {
        programType.setupFields
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppStyle.largeSpacing) {
                header
                insightCardsSection
                fieldsSection
                baselineSuggestionCard
                startDateSection
            }
            .padding(.horizontal, AppStyle.screenPadding)
            .padding(.vertical, AppStyle.largeSpacing)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onDisappear {
            populateDefaults()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: AppStyle.spacing) {
            Image(systemName: programType.iconName)
                .font(.system(size: 48))
                .foregroundColor(.neonCyan)

            Text("Customize Your Plan")
                .font(Typography.largeTitle)
                .rainbowText()
                .multilineTextAlignment(.center)

            Text(programType.tagline)
                .font(Typography.callout)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, AppStyle.spacing)
    }

    // MARK: - Start Date

    private var startDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.neonOrange)
                Text("When did you quit (or want to start)?")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
            }

            DatePicker("Start Date",
                       selection: $startDate,
                       in: Date()...,
                       displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(Typography.body)
                .padding(.top, 4)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Timezone

    private var timezoneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "globe").foregroundColor(.neonBlue)
                Text("Your Timezone").font(Typography.headline).foregroundColor(.textPrimary)
            }
            Text(TimeZone.current.identifier)
                .font(Typography.body).foregroundColor(.neonCyan)
            Text("Notifications will be scheduled based on your local time.")
                .font(Typography.caption).foregroundColor(.subtleText)
        }
        .neonCard(glow: .neonBlue)
        .onAppear {
            UserDefaults.standard.set(TimeZone.current.identifier, forKey: "userTimezone")
        }
    }

    // MARK: - Wake Time

    private var wakeTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundColor(.neonGold)
                Text("When do you usually wake up?")
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)
            }

            DatePicker("Wake time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 100)
                .clipped()
                .frame(maxWidth: .infinity)
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func saveWakeTimeDefaults() {
        let wakeHour = Calendar.current.component(.hour, from: wakeTime)
        UserDefaults.standard.set(wakeHour, forKey: "wakeUpHour")
        UserDefaults.standard.set((wakeHour + 8) % 24, forKey: "afternoonHour")
        UserDefaults.standard.set(min(wakeHour + 16, 23), forKey: "eveningHour")
    }

    // MARK: - Insight Cards

    @ViewBuilder
    private var insightCardsSection: some View {
        if let template = template {
            let visibleCards = Array(template.insightCards.prefix(2))
            if !visibleCards.isEmpty {
                VStack(spacing: AppStyle.spacing) {
                    ForEach(visibleCards) { card in
                        insightCardRow(card)
                    }
                }
            }
        }
    }

    private func insightCardRow(_ card: InsightCard) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: card.iconName)
                .font(.system(size: 20))
                .foregroundColor(.neonCyan)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)

                Text(card.body)
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Fields

    private var fieldsSection: some View {
        VStack(spacing: AppStyle.largeSpacing) {
            ForEach(fields) { field in
                fieldView(for: field)
            }
        }
    }

    @ViewBuilder
    private func fieldView(for field: ProgramSetupField) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(field.label)
                    .font(Typography.headline)
                    .foregroundColor(.textPrimary)

                if !field.unit.isEmpty {
                    Spacer()
                    Text(field.unit)
                        .font(Typography.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            switch field.fieldType {
            case .number(let range, let step):
                numberField(field: field, range: range, step: step)
            case .picker(let options):
                pickerField(field: field, options: options)
            case .time:
                timeField(field: field)
            }
        }
        .padding(AppStyle.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(AppStyle.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppStyle.cornerRadius)
                .stroke(
                    LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
                .opacity(0.4)
        )
        .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    // MARK: - Number Field (Slider)

    private func numberField(field: ProgramSetupField, range: ClosedRange<Double>, step: Double) -> some View {
        let currentValue = Double(setupValues[field.key] ?? field.placeholder) ?? range.lowerBound

        return VStack(spacing: 12) {
            // Large value display
            Text(formatNumber(currentValue, step: step))
                .font(Typography.counterLarge)
                .foregroundColor(.neonCyan)
                .frame(maxWidth: .infinity, alignment: .center)
                .shadow(color: .neonCyan.opacity(0.3), radius: 6)

            // +/- buttons with range display
            HStack(spacing: 20) {
                // Minus button
                Button {
                    let newVal = max(currentValue - step, range.lowerBound)
                    setupValues[field.key] = formatNumber(newVal, step: step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(currentValue <= range.lowerBound ? .gray.opacity(0.3) : .neonCyan)
                }
                .disabled(currentValue <= range.lowerBound)

                // Range label
                VStack(spacing: 2) {
                    Text("\(formatNumber(range.lowerBound, step: step)) – \(formatNumber(range.upperBound, step: step))")
                        .font(Typography.caption)
                        .foregroundColor(.subtleText)
                }

                // Plus button
                Button {
                    let newVal = min(currentValue + step, range.upperBound)
                    setupValues[field.key] = formatNumber(newVal, step: step)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(currentValue >= range.upperBound ? .gray.opacity(0.3) : .neonCyan)
                }
                .disabled(currentValue >= range.upperBound)
            }
        }
    }

    // MARK: - Picker Field (Dropdown Menu + Enter Manually)

    private func pickerField(field: ProgramSetupField, options: [String]) -> some View {
        let selected = setupValues[field.key] ?? ""
        let isCustomEntry = !selected.isEmpty && !options.contains(selected)

        return VStack(spacing: 10) {
            // Dropdown menu
            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        setupValues[field.key] = option
                        // Clear custom text if they pick a preset
                        if customTextFields[field.key] != nil {
                            customTextFields[field.key] = nil
                        }
                    } label: {
                        HStack {
                            Text(option)
                            if selected == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Divider()

                Button {
                    // Toggle custom entry mode
                    customTextFields[field.key] = ""
                    setupValues[field.key] = ""
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Enter manually")
                    }
                }
            } label: {
                HStack {
                    Text(selected.isEmpty ? "Select an option" : selected)
                        .font(Typography.body)
                        .foregroundColor(selected.isEmpty ? .textSecondary : .textPrimary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.neonCyan)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(
                            LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                        .opacity(0.4)
                )
            }

            // Custom text field when "Enter manually" is selected
            if customTextFields[field.key] != nil || isCustomEntry {
                HStack {
                    TextField("Type your answer", text: Binding(
                        get: { (customTextFields[field.key] ?? nil) ?? selected },
                        set: { newValue in
                            customTextFields[field.key] = newValue
                            setupValues[field.key] = newValue
                        }
                    ))
                    .font(Typography.body)
                    .foregroundColor(.textPrimary)

                    if !((customTextFields[field.key] ?? nil) ?? "").isEmpty {
                        Button {
                            customTextFields[field.key] = nil
                            setupValues[field.key] = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(AppStyle.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                        .stroke(Color.neonPurple.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Time Field

    private func timeField(field: ProgramSetupField) -> some View {
        // 12-hour display values
        let hour12Binding = Binding<Int>(
            get: {
                let h24 = currentHour(for: field.key)
                let h12 = h24 % 12
                return h12 == 0 ? 12 : h12
            },
            set: { newHour12 in
                let minute = currentMinute(for: field.key)
                let isPM = currentHour(for: field.key) >= 12
                var h24 = newHour12
                if newHour12 == 12 { h24 = isPM ? 12 : 0 }
                else if isPM { h24 = newHour12 + 12 }
                setupValues[field.key] = String(format: "%02d:%02d", h24, minute)
            }
        )

        let minuteBinding = Binding<Int>(
            get: {
                let value = setupValues[field.key] ?? ""
                let parts = value.split(separator: ":")
                if parts.count == 2, let m = Int(parts[1]) { return m }
                return 0
            },
            set: { newMinute in
                let hour = currentHour(for: field.key)
                setupValues[field.key] = String(format: "%02d:%02d", hour, newMinute)
            }
        )

        let ampmBinding = Binding<String>(
            get: {
                currentHour(for: field.key) >= 12 ? "PM" : "AM"
            },
            set: { newValue in
                let minute = currentMinute(for: field.key)
                var h24 = currentHour(for: field.key)
                let currentlyPM = h24 >= 12
                let wantPM = newValue == "PM"
                if currentlyPM && !wantPM { h24 -= 12 }
                else if !currentlyPM && wantPM { h24 += 12 }
                setupValues[field.key] = String(format: "%02d:%02d", h24, minute)
            }
        )

        return HStack(spacing: 8) {
            Spacer()

            VStack(spacing: 4) {
                Text("Hour")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                Picker("Hour", selection: hour12Binding) {
                    ForEach(1...12, id: \.self) { h in
                        Text("\(h)").tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60, height: 100)
                .clipped()
            }

            Text(":")
                .font(Typography.title)
                .foregroundColor(.neonCyan)

            VStack(spacing: 4) {
                Text("Min")
                    .font(Typography.caption)
                    .foregroundColor(.textSecondary)
                Picker("Minute", selection: minuteBinding) {
                    ForEach(Array(stride(from: 0, to: 60, by: 15)), id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60, height: 100)
                .clipped()
            }

            VStack(spacing: 4) {
                Text("")
                    .font(Typography.caption)
                Picker("AM/PM", selection: ampmBinding) {
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                }
                .pickerStyle(.wheel)
                .frame(width: 60, height: 100)
                .clipped()
            }

            Spacer()
        }
    }

    // MARK: - Baseline Suggestions

    @ViewBuilder
    private var baselineSuggestionCard: some View {
        if let template = template {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.neonGold)

                Text(template.baselineSuggestions)
                    .font(Typography.footnote)
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.neonGold.opacity(0.08))
            .cornerRadius(AppStyle.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.smallCornerRadius)
                    .stroke(Color.neonGold.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func formatNumber(_ value: Double, step: Double) -> String {
        if step >= 1 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }

    private func currentHour(for key: String) -> Int {
        let value = setupValues[key] ?? ""
        let parts = value.split(separator: ":")
        if parts.count == 2, let h = Int(parts[0]) { return h }
        return 23
    }

    private func currentMinute(for key: String) -> Int {
        let value = setupValues[key] ?? ""
        let parts = value.split(separator: ":")
        if parts.count == 2, let m = Int(parts[1]) { return m }
        return 0
    }

    /// Fills in placeholder defaults for any fields the user did not touch.
    private func populateDefaults() {
        for field in fields {
            if setupValues[field.key] == nil || setupValues[field.key]?.isEmpty == true {
                switch field.fieldType {
                case .number(let range, let step):
                    if let defaultVal = Double(field.placeholder) {
                        setupValues[field.key] = formatNumber(defaultVal, step: step)
                    } else {
                        setupValues[field.key] = formatNumber(range.lowerBound, step: step)
                    }
                case .picker(let options):
                    setupValues[field.key] = options.first ?? ""
                case .time:
                    setupValues[field.key] = "23:00"
                }
            }
        }
    }
}

// MARK: - Preview

struct ProgramSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramSetupView(
            programType: .smoking,
            setupValues: .constant([:]),
            startDate: .constant(Date()),
            onNext: {}
        )
    }
}
