import Foundation
import XCTest
@testable import CuemateApp

final class CalendarEventParserTests: XCTestCase {

    private let parser = CalendarEventParser()

    // MARK: - Basic parsing

    func testParsesTitle() throws {
        let record = try parser.parse(icsText: minimalICS(summary: "Q3 Sales Review"))
        XCTAssertEqual(record.title, "Q3 Sales Review")
    }

    func testParsesAttendeesCN() throws {
        let ics = minimalICS(extraLines: [
            "ATTENDEE;CN=Alice Smith:mailto:alice@example.com",
            "ATTENDEE;CN=\"Bob Jones\":mailto:bob@example.com",
        ])
        let record = try parser.parse(icsText: ics)
        XCTAssertTrue(record.attendeeNames.contains("Alice Smith"), "Expected Alice Smith in \(record.attendeeNames)")
        XCTAssertTrue(record.attendeeNames.contains("Bob Jones"), "Expected Bob Jones in \(record.attendeeNames)")
    }

    func testParsesDescription() throws {
        let record = try parser.parse(icsText: minimalICS(description: "Agenda:\\n1. Review Q3\\n2. Plan Q4"))
        XCTAssertTrue(record.agenda.contains("Review Q3"), "Agenda should contain unescaped text")
    }

    func testParsesLocation() throws {
        let record = try parser.parse(icsText: minimalICS(location: "Zoom / https://zoom.us/j/12345"))
        XCTAssertTrue(record.location.contains("Zoom"))
    }

    func testParsesStartDate() throws {
        let record = try parser.parse(icsText: minimalICS(dtstart: "20240515T140000Z"))
        XCTAssertNotNil(record.startDate)
    }

    func testParsesStartDateLocalFormat() throws {
        let record = try parser.parse(icsText: minimalICS(dtstart: "20240515T140000"))
        XCTAssertNotNil(record.startDate)
    }

    func testParsesAllDayDate() throws {
        let record = try parser.parse(icsText: minimalICS(dtstart: "20240515"))
        XCTAssertNotNil(record.startDate)
    }

    // MARK: - Error cases

    func testThrowsOnNonICS() {
        XCTAssertThrowsError(try parser.parse(icsText: "not a calendar file"))
    }

    func testThrowsWhenNoVEVENT() {
        let ics = "BEGIN:VCALENDAR\nVERSION:2.0\nEND:VCALENDAR"
        XCTAssertThrowsError(try parser.parse(icsText: ics))
    }

    // MARK: - calendarContextSummary

    func testContextSummaryIncludesTitle() throws {
        let record = try parser.parse(icsText: minimalICS(summary: "Board Meeting"))
        XCTAssertTrue(record.calendarContextSummary.contains("Board Meeting"))
    }

    func testContextSummaryIncludesAttendees() throws {
        let ics = minimalICS(extraLines: ["ATTENDEE;CN=Carol White:mailto:carol@example.com"])
        let record = try parser.parse(icsText: ics)
        XCTAssertTrue(record.calendarContextSummary.contains("Carol White"))
    }

    func testEmptyRecordIsEmpty() throws {
        let record = try parser.parse(icsText: minimalICS())
        XCTAssertTrue(record.isEmpty)
    }

    // MARK: - ConversationRequest carries calendarContext

    func testConversationRequestCalendarContextField() {
        let request = ConversationRequest(
            configuration: MeetingConfiguration(),
            transcriptSegments: [],
            retrievalResults: [],
            userDisplayName: "Me",
            collaboratorRoleLabel: "Them",
            sharedTranscriptMode: false,
            latestQuestion: nil,
            detectedIntent: "general",
            crossSessionMemory: "",
            meetingLanguage: "en",
            screenContext: "",
            calendarContext: "Meeting: Demo\nAttendees: Alice",
            teamContext: ""
        )
        XCTAssertTrue(request.calendarContext.contains("Demo"))
    }

    // MARK: - Helpers

    private func minimalICS(
        summary: String = "",
        dtstart: String = "20240515T140000Z",
        description: String = "",
        location: String = "",
        extraLines: [String] = []
    ) -> String {
        var lines = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "BEGIN:VEVENT",
            "DTSTART:\(dtstart)",
            "DTEND:20240515T150000Z",
        ]
        if !summary.isEmpty { lines.append("SUMMARY:\(summary)") }
        if !description.isEmpty { lines.append("DESCRIPTION:\(description)") }
        if !location.isEmpty { lines.append("LOCATION:\(location)") }
        lines += extraLines
        lines += ["END:VEVENT", "END:VCALENDAR"]
        return lines.joined(separator: "\n")
    }
}
