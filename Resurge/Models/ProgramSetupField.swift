import Foundation

struct ProgramSetupField: Identifiable {
    let id = UUID()
    let label: String
    let placeholder: String
    let unit: String
    let fieldType: FieldType
    let key: String

    enum FieldType {
        case number(range: ClosedRange<Double>, step: Double)
        case picker(options: [String])
        case time
    }
}

extension ProgramType {
    var setupFields: [ProgramSetupField] {
        switch self {
        case .smoking:
            return [
                ProgramSetupField(
                    label: "How many cigarettes per day?",
                    placeholder: "20",
                    unit: "cigarettes",
                    fieldType: .number(range: 1...60, step: 1),
                    key: "cigarettesPerDay"
                ),
                ProgramSetupField(
                    label: "How long have you been smoking?",
                    placeholder: "Select range",
                    unit: "years",
                    fieldType: .picker(options: ["Less than 1 year", "1–3 years", "3–5 years", "5–10 years", "10–20 years", "20+ years"]),
                    key: "yearsSmoking"
                )
            ]

        case .alcohol:
            return [
                ProgramSetupField(
                    label: "How many drinks per week?",
                    placeholder: "10",
                    unit: "drinks",
                    fieldType: .number(range: 1...50, step: 1),
                    key: "drinksPerWeek"
                ),
                ProgramSetupField(
                    label: "What do you mostly drink?",
                    placeholder: "Select type",
                    unit: "",
                    fieldType: .picker(options: ["Beer", "Wine", "Spirits", "Cocktails", "Hard Seltzer", "Whiskey", "Vodka", "Tequila", "Mixed"]),
                    key: "drinkType"
                ),
            ]

        case .porn:
            return [
                ProgramSetupField(
                    label: "Hours spent per day",
                    placeholder: "2",
                    unit: "hours",
                    fieldType: .number(range: 0.5...8, step: 0.5),
                    key: "hoursPerDay"
                ),
                ProgramSetupField(
                    label: "How long have you been using?",
                    placeholder: "Select range",
                    unit: "years",
                    fieldType: .picker(options: ["Less than 1 year", "1–3 years", "3–5 years", "5–10 years", "10–20 years", "20+ years"]),
                    key: "yearsOfUse"
                ),
                ProgramSetupField(
                    label: "Sessions per day",
                    placeholder: "3",
                    unit: "sessions",
                    fieldType: .number(range: 1...10, step: 1),
                    key: "sessionsPerDay"
                )
            ]

        case .phone:
            return [
                ProgramSetupField(
                    label: "Total screen time (hours/day)",
                    placeholder: "6",
                    unit: "hours",
                    fieldType: .number(range: 1...16, step: 0.5),
                    key: "screenTimeHoursPerDay"
                ),
                ProgramSetupField(
                    label: "Hours wasted on non-essential use",
                    placeholder: "4",
                    unit: "hours",
                    fieldType: .number(range: 1...12, step: 0.5),
                    key: "wastedHoursPerDay"
                )
            ]

        case .socialMedia:
            return [
                ProgramSetupField(
                    label: "Hours on social media per day",
                    placeholder: "3",
                    unit: "hours",
                    fieldType: .number(range: 0.5...12, step: 0.5),
                    key: "socialMediaHoursPerDay"
                ),
                ProgramSetupField(
                    label: "How many platforms do you use?",
                    placeholder: "4",
                    unit: "platforms",
                    fieldType: .number(range: 1...10, step: 1),
                    key: "platformCount"
                ),
                ProgramSetupField(
                    label: "Times you check your phone per day",
                    placeholder: "30",
                    unit: "times",
                    fieldType: .number(range: 1...100, step: 1),
                    key: "checksPerDay"
                )
            ]

        case .gaming:
            return [
                ProgramSetupField(
                    label: "Hours gaming per day",
                    placeholder: "4",
                    unit: "hours",
                    fieldType: .number(range: 1...16, step: 0.5),
                    key: "gamingHoursPerDay"
                ),
                ProgramSetupField(
                    label: "How long have you been gaming?",
                    placeholder: "Select range",
                    unit: "years",
                    fieldType: .picker(options: ["Less than 1 year", "1–3 years", "3–5 years", "5–10 years", "10–20 years", "20+ years"]),
                    key: "yearsGaming"
                )
            ]

        case .sugar:
            return [
                ProgramSetupField(
                    label: "Sugary items consumed per day",
                    placeholder: "5",
                    unit: "sugary items",
                    fieldType: .number(range: 1...20, step: 1),
                    key: "sugaryItemsPerDay"
                ),
                ProgramSetupField(
                    label: "What type of sugar do you consume most?",
                    placeholder: "Select type",
                    unit: "",
                    fieldType: .picker(options: ["Candy & Chocolate", "Soda & Sugary Drinks", "Desserts & Baked Goods", "Ice Cream", "Cookies & Pastries", "Energy Drinks", "Juice & Smoothies", "Cereal & Granola Bars", "All of the Above"]),
                    key: "sugarType"
                )
            ]

        case .emotionalEating:
            return [
                ProgramSetupField(
                    label: "Emotional eating episodes per week",
                    placeholder: "5",
                    unit: "episodes",
                    fieldType: .number(range: 1...14, step: 1),
                    key: "episodesPerWeek"
                ),
            ]

        case .shopping:
            return [
                ProgramSetupField(
                    label: "Impulse purchases per week",
                    placeholder: "5",
                    unit: "impulse purchases",
                    fieldType: .number(range: 1...20, step: 1),
                    key: "purchasesPerWeek"
                ),
            ]

        case .gambling:
            return [
                ProgramSetupField(
                    label: "Betting sessions per week",
                    placeholder: "3",
                    unit: "betting sessions",
                    fieldType: .number(range: 1...14, step: 1),
                    key: "sessionsPerWeek"
                ),
                ProgramSetupField(
                    label: "Type of gambling",
                    placeholder: "Select type",
                    unit: "",
                    fieldType: .picker(options: ["Sports Betting", "Casino", "Online Casino", "Poker", "Slot Machines", "Horse Racing", "Lottery & Scratch Cards", "Fantasy Sports", "Crypto Trading", "Day Trading", "Bingo"]),
                    key: "gamblingType"
                )
            ]
        }
    }

    var unitLabel: String {
        switch self {
        case .smoking:          return "cigarettes"
        case .alcohol:          return "drinks"
        case .porn:             return "sessions"
        case .phone:            return "hours of screen time"
        case .socialMedia:      return "hours on social media"
        case .gaming:           return "hours gaming"
        case .sugar:            return "sugary items"
        case .emotionalEating:  return "episodes"
        case .shopping:         return "impulse purchases"
        case .gambling:         return "betting sessions"
        }
    }
}
