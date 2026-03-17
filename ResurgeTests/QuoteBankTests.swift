import XCTest
@testable import Resurge

final class QuoteBankTests: XCTestCase {

    // MARK: - Quote Bank Not Empty

    func testQuoteBankIsNotEmpty() {
        XCTAssertGreaterThan(QuoteBank.allQuotes.count, 0, "Quote bank should not be empty")
    }

    func testQuoteBankHasOver200Quotes() {
        XCTAssertGreaterThanOrEqual(QuoteBank.allQuotes.count, 200,
            "Quote bank should have at least 200 quotes")
    }

    // MARK: - Quote of the Day

    func testQuoteOfTheDayReturnsAQuote() {
        let quote = QuoteBank.quoteOfTheDay()
        XCTAssertFalse(quote.text.isEmpty, "Quote of the day should have text")
        XCTAssertFalse(quote.author.isEmpty, "Quote of the day should have an author")
    }

    func testQuoteOfTheDayIsDeterministic() {
        let first = QuoteBank.quoteOfTheDay()
        let second = QuoteBank.quoteOfTheDay()
        XCTAssertEqual(first.id, second.id,
            "Quote of the day should return the same quote when called twice on the same day")
    }

    func testQuoteOfTheDayWithProgramType() {
        let quote = QuoteBank.quoteOfTheDay(for: .smoking)
        XCTAssertFalse(quote.text.isEmpty, "Quote of the day for smoking should have text")
    }

    func testQuoteOfTheDayDeterministicWithProgramType() {
        let first = QuoteBank.quoteOfTheDay(for: .alcohol)
        let second = QuoteBank.quoteOfTheDay(for: .alcohol)
        XCTAssertEqual(first.id, second.id,
            "Quote of the day should be deterministic for the same program type")
    }

    // MARK: - Random Quote

    func testRandomQuoteReturnsAQuote() {
        let quote = QuoteBank.randomQuote()
        XCTAssertFalse(quote.text.isEmpty, "Random quote should have text")
        XCTAssertFalse(quote.author.isEmpty, "Random quote should have an author")
    }

    func testRandomQuoteWithProgramType() {
        let quote = QuoteBank.randomQuote(for: .gaming)
        XCTAssertFalse(quote.text.isEmpty, "Random quote for gaming should have text")
    }

    // MARK: - Program Type Filtering

    func testAllProgramTypesHaveQuotes() {
        let programTypes: [ProgramType] = [
            .smoking, .alcohol, .porn, .phone, .socialMedia, .gaming,
            .procrastination, .sugar, .emotionalEating, .shopping, .gambling, .sleep
        ]

        for program in programTypes {
            let filtered = QuoteBank.allQuotes.filter { quote in
                quote.programTypes?.contains(program) ?? false
            }
            XCTAssertGreaterThan(filtered.count, 0,
                "\(program.rawValue) should have program-specific quotes")
        }
    }

    func testSmokingQuotesAreRelevant() {
        let smokingQuotes = QuoteBank.allQuotes.filter { quote in
            quote.programTypes?.contains(.smoking) ?? false
        }
        XCTAssertGreaterThanOrEqual(smokingQuotes.count, 5,
            "Smoking should have at least 5 specific quotes")
    }

    func testUniversalQuotesExist() {
        let universalQuotes = QuoteBank.allQuotes.filter { $0.programTypes == nil }
        XCTAssertGreaterThan(universalQuotes.count, 0,
            "There should be universal quotes (nil programTypes)")
    }

    func testFilteredPoolIncludesUniversalQuotes() {
        // When filtering for a program type, universal quotes (nil) should be included
        let allForSmoking = QuoteBank.allQuotes.filter { quote in
            quote.programTypes == nil || quote.programTypes!.contains(.smoking)
        }
        let universalCount = QuoteBank.allQuotes.filter { $0.programTypes == nil }.count
        XCTAssertGreaterThan(allForSmoking.count, universalCount,
            "Filtered pool should include universal quotes plus program-specific ones")
    }

    // MARK: - Quote Properties

    func testQuoteIDsAreUnique() {
        let ids = Set(QuoteBank.allQuotes.map(\.id))
        XCTAssertEqual(ids.count, QuoteBank.allQuotes.count, "All quote IDs should be unique")
    }

    func testAllQuotesHaveNonEmptyText() {
        for quote in QuoteBank.allQuotes {
            XCTAssertFalse(quote.text.isEmpty, "Quote \(quote.id) should have non-empty text")
            XCTAssertFalse(quote.author.isEmpty, "Quote \(quote.id) should have non-empty author")
        }
    }
}
