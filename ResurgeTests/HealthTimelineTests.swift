import XCTest
@testable import Resurge

final class HealthTimelineTests: XCTestCase {

    // MARK: - Coverage

    func testEveryProgramTypeHasAtLeastOneMilestone() {
        for program in ProgramType.allCases {
            let milestones = HealthMilestone.milestones(for: program)
            XCTAssertGreaterThan(milestones.count, 0,
                "\(program.rawValue) should have at least one health milestone")
        }
    }

    // MARK: - Sorting

    func testMilestonesAreSortedByRequiredMinutes() {
        for program in ProgramType.allCases {
            let milestones = HealthMilestone.milestones(for: program)
            for i in 1..<milestones.count {
                XCTAssertLessThanOrEqual(milestones[i - 1].requiredMinutes, milestones[i].requiredMinutes,
                    "\(program.rawValue) milestones should be sorted by requiredMinutes, but \(milestones[i - 1].requiredMinutes) > \(milestones[i].requiredMinutes)")
            }
        }
    }

    // MARK: - Required Minutes

    func testRequiredMinutesIsAlwaysPositive() {
        for program in ProgramType.allCases {
            let milestones = HealthMilestone.milestones(for: program)
            for milestone in milestones {
                XCTAssertGreaterThan(milestone.requiredMinutes, 0,
                    "\(program.rawValue) milestone '\(milestone.title)' should have requiredMinutes > 0")
            }
        }
    }

    // MARK: - Time Description

    func testTimeDescriptionIsNeverEmpty() {
        for program in ProgramType.allCases {
            let milestones = HealthMilestone.milestones(for: program)
            for milestone in milestones {
                XCTAssertFalse(milestone.timeDescription.isEmpty,
                    "\(program.rawValue) milestone '\(milestone.title)' should have a non-empty timeDescription")
            }
        }
    }

    // MARK: - Description

    func testDescriptionIsNeverEmpty() {
        for program in ProgramType.allCases {
            let milestones = HealthMilestone.milestones(for: program)
            for milestone in milestones {
                XCTAssertFalse(milestone.description.isEmpty,
                    "\(program.rawValue) milestone '\(milestone.title)' should have a non-empty description")
            }
        }
    }
}
