import XCTest
@testable import Resurge

final class AchievementEvaluationTests: XCTestCase {

    func testMilestoneBadgesExist() {
        let badges = MilestoneBadge.allBadges
        XCTAssertGreaterThan(badges.count, 5, "Should have multiple milestone badges")
    }

    func testBadgesAreSortedByDays() {
        let badges = MilestoneBadge.allBadges
        for i in 0..<badges.count - 1 {
            XCTAssertLessThanOrEqual(badges[i].requiredDays, badges[i + 1].requiredDays,
                "Badges should be sorted by required days")
        }
    }

    func testOneDayBadgeExists() {
        let badge = MilestoneBadge.allBadges.first { $0.requiredDays == 1 }
        XCTAssertNotNil(badge, "Should have a 1-day milestone badge")
    }

    func testOneWeekBadgeExists() {
        let badge = MilestoneBadge.allBadges.first { $0.requiredDays == 7 }
        XCTAssertNotNil(badge, "Should have a 7-day milestone badge")
    }

    func testOneMonthBadgeExists() {
        let badge = MilestoneBadge.allBadges.first { $0.requiredDays == 30 }
        XCTAssertNotNil(badge, "Should have a 30-day milestone badge")
    }

    func testOneYearBadgeExists() {
        let badge = MilestoneBadge.allBadges.first { $0.requiredDays == 365 }
        XCTAssertNotNil(badge, "Should have a 365-day milestone badge")
    }

    func testBadgeKeysAreUnique() {
        let badges = MilestoneBadge.allBadges
        let keys = Set(badges.map(\.key))
        XCTAssertEqual(keys.count, badges.count, "All badge keys should be unique")
    }

    func testEligibleBadgesForDays() {
        let allBadges = MilestoneBadge.allBadges
        let eligible = allBadges.filter { $0.requiredDays <= 14 }
        // Should include: 1 day, 3 days, 7 days, 14 days
        XCTAssertGreaterThanOrEqual(eligible.count, 3, "14 days should unlock at least 3 badges")
    }

    func testProgramTypeEnumCoverage() {
        // Ensure all 12 required programs exist
        let required: [ProgramType] = [
            .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
            .procrastination, .sugar, .emotionalEating, .shopping, .gambling, .sleep
        ]
        for program in required {
            XCTAssertNotNil(ProgramTemplates.template(for: program),
                "Template should exist for \(program.rawValue)")
        }
    }

    func testProgramTemplatesHaveRequiredFields() {
        for template in ProgramTemplates.all {
            XCTAssertFalse(template.defaultTriggers.isEmpty, "\(template.id) should have triggers")
            XCTAssertFalse(template.defaultCopingTools.isEmpty, "\(template.id) should have coping tools")
            XCTAssertFalse(template.defaultMetrics.isEmpty, "\(template.id) should have metrics")
            XCTAssertFalse(template.insightCards.isEmpty, "\(template.id) should have insight cards")
            XCTAssertFalse(template.uniqueToolIdentifier.isEmpty, "\(template.id) should have unique tool ID")
        }
    }
}
