import SwiftUI

/// Shows the user's active pet if they've purchased one.
/// Place this next to navigation titles on each tab.
struct ActivePetView: View {
    @AppStorage("activePet") private var activePet: String = ""

    var body: some View {
        if !activePet.isEmpty {
            petView
        }
    }

    @ViewBuilder
    private var petView: some View {
        switch activePet {
        case "pet_dog": DogPetView(size: 32)
        case "pet_cat": CatPetView(size: 32)
        case "pet_hamster": HamsterPetView(size: 32)
        case "pet_owl": OwlPetView(size: 32)
        default: EmptyView()
        }
    }
}
