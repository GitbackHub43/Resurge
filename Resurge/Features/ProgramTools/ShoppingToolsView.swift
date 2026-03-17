import SwiftUI
import Combine

// MARK: - Shopping Tools View

struct ShoppingToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("Cart Quarantine").tag(0)
                    Text("Wishlist Later").tag(1)
                    Text("Spending Log").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: CartQuarantineCard()
                case 1: WishlistLaterCard()
                default: ImpulseSpendingCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Shopping Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Cart Quarantine

private struct QuarantineItem: Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    let addedAt: Date
    var expiresAt: Date
    var decided: Bool = false
    var purchased: Bool = false
}

private struct CartQuarantineCard: View {
    @State private var items: [QuarantineItem] = [
        QuarantineItem(
            name: "Wireless Headphones",
            price: 79.99,
            addedAt: Calendar.current.date(byAdding: .hour, value: -20, to: Date()) ?? Date(),
            expiresAt: Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date()
        ),
        QuarantineItem(
            name: "Running Shoes",
            price: 129.00,
            addedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            expiresAt: Calendar.current.date(byAdding: .hour, value: 22, to: Date()) ?? Date()
        ),
    ]
    @State private var newItemName = ""
    @State private var newItemPrice = ""
    @State private var now = Date()
    @State private var timerCancellable: AnyCancellable?

    private var totalQuarantined: Double {
        items.filter { !$0.decided }.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("24-Hour Cart Quarantine", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                    .foregroundColor(Color.neonOrange)
                Spacer()
            }

            Text("Add items you want to buy. Wait 24 hours, then decide with a clear head.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            // Add item
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                        .foregroundColor(Color.neonOrange)
                    TextField("Item name", text: $newItemName)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(Color.neonGold)
                    TextField("Price", text: $newItemPrice)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                Button {
                    guard !newItemName.isEmpty, let price = Double(newItemPrice) else { return }
                    let item = QuarantineItem(
                        name: newItemName,
                        price: price,
                        addedAt: Date(),
                        expiresAt: Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
                    )
                    withAnimation {
                        items.insert(item, at: 0)
                        newItemName = ""
                        newItemPrice = ""
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Quarantine Item")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(newItemName.isEmpty ? Color.gray.opacity(0.3) : Color.neonOrange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(newItemName.isEmpty)
            }

            if !items.isEmpty {
                Text(String(format: "Quarantined value: $%.2f", totalQuarantined))
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color.neonGold)

                ForEach($items) { $item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(Font.subheadline.weight(.medium))
                                Text(String(format: "$%.2f", item.price))
                                    .font(.caption)
                                    .foregroundColor(Color.neonGold)
                            }
                            Spacer()

                            if item.decided {
                                Text(item.purchased ? "Bought" : "Skipped")
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(item.purchased ? Color.neonOrange : Color.neonCyan)
                            } else {
                                let remaining = item.expiresAt.timeIntervalSince(now)
                                if remaining > 0 {
                                    Text(formatCountdown(remaining))
                                        .font(Font.caption.weight(.bold))
                                        .foregroundColor(Color.neonOrange)
                                } else {
                                    HStack(spacing: 8) {
                                        Button {
                                            withAnimation { item.decided = true; item.purchased = false }
                                        } label: {
                                            Text("Skip")
                                                .font(Font.caption.weight(.bold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.neonCyan)
                                                .foregroundColor(.white)
                                                .cornerRadius(6)
                                        }
                                        Button {
                                            withAnimation { item.decided = true; item.purchased = true }
                                        } label: {
                                            Text("Buy")
                                                .font(Font.caption.weight(.bold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.appBackground)
                                                .foregroundColor(Color.subtleText)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
        .onAppear { startClock() }
    }

    private func formatCountdown(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m left"
    }

    private func startClock() {
        timerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in now = Date() }
    }
}

// MARK: - Wishlist Later

private struct WishlistItem: Identifiable {
    let id = UUID()
    var name: String
    var price: Double
    let addedAt: Date
    var revisitDate: Date
}

private struct WishlistLaterCard: View {
    @State private var items: [WishlistItem] = [
        WishlistItem(name: "Smart Watch", price: 249.00, addedAt: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(), revisitDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()),
        WishlistItem(name: "Designer Jacket", price: 180.00, addedAt: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(), revisitDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()),
        WishlistItem(name: "Espresso Machine", price: 320.00, addedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), revisitDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()),
    ]
    @State private var newName = ""
    @State private var newPrice = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Wishlist Later", systemImage: "bookmark.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            Text("Save items to revisit in 30 days. If you still want it then, maybe it is worth it.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(Color.neonCyan)
                    TextField("Item", text: $newName)
                        .font(.subheadline)
                }
                .padding(10)
                .background(Color.appBackground)
                .cornerRadius(8)

                HStack {
                    Text("$")
                        .foregroundColor(Color.neonGold)
                    TextField("Price", text: $newPrice)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                }
                .padding(10)
                .frame(width: 100)
                .background(Color.appBackground)
                .cornerRadius(8)

                Button {
                    guard !newName.isEmpty, let price = Double(newPrice) else { return }
                    let item = WishlistItem(
                        name: newName,
                        price: price,
                        addedAt: Date(),
                        revisitDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                    )
                    withAnimation {
                        items.insert(item, at: 0)
                        newName = ""
                        newPrice = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(newName.isEmpty ? Color.gray.opacity(0.3) : Color.neonCyan)
                }
                .disabled(newName.isEmpty)
            }

            if !items.isEmpty {
                ForEach(items) { item in
                    let daysUntilRevisit = Calendar.current.dateComponents([.day], from: Date(), to: item.revisitDate).day ?? 0

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(Font.subheadline.weight(.medium))
                            Text(String(format: "$%.2f", item.price))
                                .font(.caption)
                                .foregroundColor(Color.neonGold)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if daysUntilRevisit > 0 {
                                Text("\(daysUntilRevisit) days left")
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(Color.neonOrange)
                            } else {
                                Text("Ready to revisit")
                                    .font(Font.caption.weight(.bold))
                                    .foregroundColor(Color.neonCyan)
                            }
                            Text("Added \(item.addedAt, style: .date)")
                                .font(.system(size: 9))
                                .foregroundColor(Color.subtleText)
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Impulse Spending Tracker

private struct ImpulseEntry: Identifiable {
    let id = UUID()
    let item: String
    let amount: Double
    let date: Date
    let resisted: Bool
}

private struct ImpulseSpendingCard: View {
    @State private var entries: [ImpulseEntry] = [
        ImpulseEntry(item: "Coffee machine", amount: 89.99, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), resisted: true),
        ImpulseEntry(item: "Sale shoes", amount: 65.00, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), resisted: true),
        ImpulseEntry(item: "Phone case", amount: 25.00, date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), resisted: false),
    ]
    @State private var newItem = ""
    @State private var newAmount = ""
    @State private var newResisted = true

    private var totalSaved: Double {
        entries.filter(\.resisted).reduce(0) { $0 + $1.amount }
    }

    private var totalSpent: Double {
        entries.filter { !$0.resisted }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Impulse Spending Tracker", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundColor(Color.neonPurple)

            // Summary
            HStack {
                VStack {
                    Text(String(format: "$%.2f", totalSaved))
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Saved")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)

                Divider().frame(height: 40)

                VStack {
                    Text(String(format: "$%.2f", totalSpent))
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonOrange)
                    Text("Impulse Spent")
                        .font(.caption)
                        .foregroundColor(Color.subtleText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.appBackground)
            .cornerRadius(12)

            // Log entry
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "cart")
                        .foregroundColor(Color.neonGold)
                    TextField("What was the impulse?", text: $newItem)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(Color.neonGold)
                    TextField("Amount", text: $newAmount)
                        .font(.subheadline)
                        .keyboardType(.decimalPad)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                HStack(spacing: 12) {
                    Button {
                        newResisted = true
                    } label: {
                        HStack {
                            Image(systemName: newResisted ? "checkmark.circle.fill" : "circle")
                            Text("Resisted")
                        }
                        .font(Font.subheadline.weight(newResisted ? .bold : .regular))
                        .foregroundColor(newResisted ? Color.neonCyan : Color.subtleText)
                    }
                    .buttonStyle(.plain)

                    Button {
                        newResisted = false
                    } label: {
                        HStack {
                            Image(systemName: !newResisted ? "checkmark.circle.fill" : "circle")
                            Text("Gave In")
                        }
                        .font(Font.subheadline.weight(!newResisted ? .bold : .regular))
                        .foregroundColor(!newResisted ? Color.neonOrange : Color.subtleText)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    guard !newItem.isEmpty, let amount = Double(newAmount) else { return }
                    let entry = ImpulseEntry(item: newItem, amount: amount, date: Date(), resisted: newResisted)
                    withAnimation {
                        entries.insert(entry, at: 0)
                        newItem = ""
                        newAmount = ""
                        newResisted = true
                    }
                } label: {
                    Text("Log Impulse")
                        .font(Font.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(newItem.isEmpty ? Color.gray.opacity(0.3) : Color.neonGold)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(newItem.isEmpty)
            }

            // Entries list
            if !entries.isEmpty {
                ForEach(entries) { entry in
                    HStack {
                        Image(systemName: entry.resisted ? "shield.fill" : "exclamationmark.circle")
                            .foregroundColor(entry.resisted ? Color.neonCyan : Color.neonOrange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.item)
                                .font(.subheadline)
                            Text(entry.date, style: .date)
                                .font(.caption2)
                                .foregroundColor(Color.subtleText)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "$%.2f", entry.amount))
                                .font(Font.subheadline.weight(.bold))
                                .foregroundColor(entry.resisted ? Color.neonCyan : Color.neonOrange)
                            Text(entry.resisted ? "Saved" : "Spent")
                                .font(.caption2)
                                .foregroundColor(Color.subtleText)
                        }
                    }
                    .padding(10)
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }
}

// MARK: - Preview

struct ShoppingToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShoppingToolsView()
        }
    }
}
