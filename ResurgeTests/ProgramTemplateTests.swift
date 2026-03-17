import XCTest
@testable import Resurge

final class ProgramTemplateTests: XCTestCase {

    /// All program types that should have a template (excludes .custom)
    private let templateProgramTypes: [ProgramType] = [
        .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
        .procrastination, .sugar, .emotionalEating, .shopping, .gambling, .sleep
    ]

    // MARK: - Template Coverage

    func testEveryProgramTypeHasAMatchingTemplate() {
        for program in templateProgramTypes {
            let template = ProgramTemplates.template(for: program)
            XCTAssertNotNil(template,
                "\(program.rawValue) should have a matching ProgramTemplate")
        }
    }

    // MARK: - Triggers

    func testEachTemplateHasAtLeastOneTrigger() {
        for template in ProgramTemplates.all {
            XCTAssertGreaterThan(template.defaultTriggers.count, 0,
                "\(template.id) template should have at least one trigger")
        }
    }

    // MARK: - Coping Tools

    func testEachTemplateHasAtLeastOneCopingTool() {
        for template in ProgramTemplates.all {
            XCTAssertGreaterThan(template.defaultCopingTools.count, 0,
                "\(template.id) template should have at least one coping tool")
        }
    }

    // MARK: - Metrics

    func testEachTemplateHasAtLeastOneMetric() {
        for template in ProgramTemplates.all {
            XCTAssertGreaterThan(template.defaultMetrics.count, 0,
                "\(template.id) template should have at least one metric")
        }
    }

    // MARK: - Program Type Consistency

    func testTemplateProgramTypesMatchTheirKeys() {
        for program in templateProgramTypes {
            guard let template = ProgramTemplates.template(for: program) else {
                XCTFail("\(program.rawValue) template not found")
                continue
            }
            XCTAssertEqual(template.programType, program,
                "Template looked up for \(program.rawValue) should have matching programType")
        }
    }

    // MARK: - No Duplicate Triggers

    func testNoDuplicateTriggersWithinATemplate() {
        for template in ProgramTemplates.all {
            let uniqueTriggers = Set(template.defaultTriggers)
            XCTAssertEqual(uniqueTriggers.count, template.defaultTriggers.count,
                "\(template.id) template should not have duplicate triggers")
        }
    }
}
