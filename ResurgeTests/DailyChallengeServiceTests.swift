import XCTest
@testable import Resurge

final class DailyChallengeServiceTests: XCTestCase {

    // MARK: - Challenge for Day

    func testChallengeForDayReturnsChallenge() {
        let challenge = DailyChallengeService.challengeForDay(1, programType: .smoking)
        XCTAssertFalse(challenge.title.isEmpty, "Challenge should have a title")
        XCTAssertFalse(challenge.description.isEmpty, "Challenge should have a description")
    }

    func testDifferentDaysReturnDifferentChallenges() {
        let challenge1 = DailyChallengeService.challengeForDay(1, programType: .smoking)
        let challenge2 = DailyChallengeService.challengeForDay(2, programType: .smoking)
        // Different days within same phase should cycle through pool
        XCTAssertNotEqual(challenge1.id, challenge2.id,
            "Different days should return different challenges")
    }

    func testDeterministicSelection() {
        let first = DailyChallengeService.challengeForDay(5, programType: .alcohol)
        let second = DailyChallengeService.challengeForDay(5, programType: .alcohol)
        XCTAssertEqual(first.id, second.id, "Same day should always return the same challenge")
    }

    // MARK: - Phase Detection

    func testDetoxPhase() {
        for day in 1...7 {
            let phase = RecoveryPhase.phase(for: day)
            XCTAssertEqual(phase, .detox, "Day \(day) should be detox phase")
        }
    }

    func testBuildingPhase() {
        for day in [8, 15, 30] {
            let phase = RecoveryPhase.phase(for: day)
            XCTAssertEqual(phase, .building, "Day \(day) should be building phase")
        }
    }

    func testStrengtheningPhase() {
        for day in [31, 60, 90] {
            let phase = RecoveryPhase.phase(for: day)
            XCTAssertEqual(phase, .strengthening, "Day \(day) should be strengthening phase")
        }
    }

    func testMaintainingPhase() {
        for day in [91, 100, 365] {
            let phase = RecoveryPhase.phase(for: day)
            XCTAssertEqual(phase, .maintaining, "Day \(day) should be maintaining phase")
        }
    }

    func testDayZeroIsDetox() {
        let phase = RecoveryPhase.phase(for: 0)
        XCTAssertEqual(phase, .detox, "Day 0 should be detox phase")
    }

    // MARK: - All Phases Have Challenges

    func testDetoxPhaseChallengesExist() {
        let challenges = DailyChallengeService.challenges(for: .detox)
        XCTAssertGreaterThan(challenges.count, 0, "Detox phase should have challenges")
    }

    func testBuildingPhaseChallengesExist() {
        let challenges = DailyChallengeService.challenges(for: .building)
        XCTAssertGreaterThan(challenges.count, 0, "Building phase should have challenges")
    }

    func testStrengtheningPhaseChallengesExist() {
        let challenges = DailyChallengeService.challenges(for: .strengthening)
        XCTAssertGreaterThan(challenges.count, 0, "Strengthening phase should have challenges")
    }

    func testMaintainingPhaseChallengesExist() {
        let challenges = DailyChallengeService.challenges(for: .maintaining)
        XCTAssertGreaterThan(challenges.count, 0, "Maintaining phase should have challenges")
    }

    // MARK: - Challenge Properties

    func testChallengesHaveUniqueIDs() {
        for phase in RecoveryPhase.allCases {
            let challenges = DailyChallengeService.challenges(for: phase)
            let ids = Set(challenges.map(\.id))
            XCTAssertEqual(ids.count, challenges.count,
                "\(phase.rawValue) challenges should have unique IDs")
        }
    }

    func testChallengesHaveCorrectPhase() {
        for phase in RecoveryPhase.allCases {
            let challenges = DailyChallengeService.challenges(for: phase)
            for challenge in challenges {
                XCTAssertEqual(challenge.phase, phase,
                    "Challenge '\(challenge.title)' should have phase \(phase.rawValue)")
            }
        }
    }

    func testChallengesHaveIconNames() {
        for phase in RecoveryPhase.allCases {
            let challenges = DailyChallengeService.challenges(for: phase)
            for challenge in challenges {
                XCTAssertFalse(challenge.iconName.isEmpty,
                    "Challenge '\(challenge.title)' should have an icon name")
            }
        }
    }

    // MARK: - Phase Boundary

    func testPhaseBoundaryDay7to8() {
        let day7Challenge = DailyChallengeService.challengeForDay(7, programType: .smoking)
        let day8Challenge = DailyChallengeService.challengeForDay(8, programType: .smoking)
        XCTAssertEqual(day7Challenge.phase, .detox, "Day 7 challenge should be detox")
        XCTAssertEqual(day8Challenge.phase, .building, "Day 8 challenge should be building")
    }

    func testPhaseBoundaryDay30to31() {
        let day30Challenge = DailyChallengeService.challengeForDay(30, programType: .alcohol)
        let day31Challenge = DailyChallengeService.challengeForDay(31, programType: .alcohol)
        XCTAssertEqual(day30Challenge.phase, .building, "Day 30 challenge should be building")
        XCTAssertEqual(day31Challenge.phase, .strengthening, "Day 31 challenge should be strengthening")
    }

    func testPhaseBoundaryDay90to91() {
        let day90Challenge = DailyChallengeService.challengeForDay(90, programType: .phone)
        let day91Challenge = DailyChallengeService.challengeForDay(91, programType: .phone)
        XCTAssertEqual(day90Challenge.phase, .strengthening, "Day 90 challenge should be strengthening")
        XCTAssertEqual(day91Challenge.phase, .maintaining, "Day 91 challenge should be maintaining")
    }
}
