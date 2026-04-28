import Foundation
import XCTest
@testable import CuemateApp

final class CrossSessionMemoryTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(
        participantName: String = "",
        participantCompany: String = "",
        meetingType: String = "sales",
        preferredAnswerStyle: String = "",
        summary: MeetingSummary? = nil,
        outcome: SessionOutcome? = nil,
        isActive: Bool = false
    ) -> MeetingSessionRecord {
        var config = MeetingConfiguration()
        config.participantName = participantName
        config.participantCompany = participantCompany
        config.meetingType = meetingType
        config.preferredAnswerStyle = preferredAnswerStyle

        return MeetingSessionRecord(
            id: UUID(),
            title: "Test Session",
            startedAt: Date(timeIntervalSinceNow: -3600),
            endedAt: isActive ? nil : Date(timeIntervalSinceNow: -60),
            configuration: config,
            transcriptSegments: [],
            guidanceHistory: [],
            documentIDs: [],
            diagnostics: SessionDiagnostics(),
            summary: summary,
            followUpNotes: "",
            brief: nil,
            followUpArtifact: nil,
            sessionOutcome: outcome
        )
    }

    private func makeSummary(
        overview: String = "Good session.",
        keyTopics: [String] = [],
        actionItems: [String] = [],
        outcomeNote: String = ""
    ) -> MeetingSummary {
        MeetingSummary(
            overview: overview,
            keyTopics: keyTopics,
            actionItems: actionItems,
            outcomeNote: outcomeNote,
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )
    }

    // MARK: - CM-BLG-090: Cross-session memory

    func testEmptyMemoryWhenNoPastSessions() {
        var config = MeetingConfiguration()
        config.meetingType = "sales"
        let note = CrossSessionMemoryBuilder().build(for: config, from: [])
        XCTAssertTrue(note.isEmpty)
        XCTAssertEqual(note.sessionCount, 0)
    }

    func testMemoryMatchesByParticipantName() {
        var config = MeetingConfiguration()
        config.participantName = "Sarah"
        config.meetingType = "sales"

        let matchingSession = makeSession(
            participantName: "Sarah",
            meetingType: "sales",
            summary: makeSummary(keyTopics: ["budget", "timeline"]),
            outcome: .pilot
        )
        let unrelatedSession = makeSession(
            participantName: "Bob",
            meetingType: "sales",
            summary: makeSummary(keyTopics: ["roadmap"])
        )

        let note = CrossSessionMemoryBuilder().build(for: config, from: [matchingSession, unrelatedSession])
        XCTAssertFalse(note.isEmpty)
        XCTAssertTrue(note.text.contains("Sarah"))
        XCTAssertEqual(note.sessionCount, 1)
    }

    func testMemoryFallsBackToMeetingTypeWhenNoParticipantName() {
        var config = MeetingConfiguration()
        config.meetingType = "sales"

        let session1 = makeSession(meetingType: "sales", summary: makeSummary(keyTopics: ["pilot"]))
        let session2 = makeSession(meetingType: "sales", summary: makeSummary(keyTopics: ["budget"]))
        let differentType = makeSession(meetingType: "interview")

        let note = CrossSessionMemoryBuilder().build(for: config, from: [session1, session2, differentType])
        XCTAssertFalse(note.isEmpty)
        XCTAssertEqual(note.sessionCount, 2)
    }

    func testMemoryIncludesLastOutcome() {
        var config = MeetingConfiguration()
        config.meetingType = "sales"

        let session = makeSession(
            meetingType: "sales",
            summary: makeSummary(outcomeNote: "Pilot approved next quarter."),
            outcome: .pilot
        )

        let note = CrossSessionMemoryBuilder().build(for: config, from: [session])
        XCTAssertTrue(note.text.lowercased().contains("pilot"))
    }

    func testMemoryIncludesRecurringTopics() {
        var config = MeetingConfiguration()
        config.meetingType = "sales"

        let sessions = [
            makeSession(meetingType: "sales", summary: makeSummary(keyTopics: ["budget", "timeline"])),
            makeSession(meetingType: "sales", summary: makeSummary(keyTopics: ["budget", "integration"])),
        ]

        let note = CrossSessionMemoryBuilder().build(for: config, from: sessions)
        XCTAssertTrue(note.text.lowercased().contains("budget"), "budget should appear as top recurring topic")
    }

    func testActiveSessionsAreExcluded() {
        var config = MeetingConfiguration()
        config.meetingType = "sales"

        let activeSession = makeSession(meetingType: "sales", isActive: true)
        let completedSession = makeSession(meetingType: "sales")

        let note = CrossSessionMemoryBuilder().build(for: config, from: [activeSession, completedSession])
        XCTAssertEqual(note.sessionCount, 1)
    }

    // MARK: - CM-BLG-091: Style learning

    func testSuggestedStyleReturnsNilWithInsufficientHistory() {
        let sessions = [makeSession(meetingType: "sales", preferredAnswerStyle: "assertive")]
        let suggested = CrossSessionMemoryBuilder().suggestedAnswerStyle(meetingType: "sales", from: sessions)
        XCTAssertNil(suggested, "Should require at least 2 sessions")
    }

    func testSuggestedStyleReturnsMostFrequent() {
        let sessions = [
            makeSession(meetingType: "sales", preferredAnswerStyle: "assertive"),
            makeSession(meetingType: "sales", preferredAnswerStyle: "assertive"),
            makeSession(meetingType: "sales", preferredAnswerStyle: "balanced"),
        ]
        let suggested = CrossSessionMemoryBuilder().suggestedAnswerStyle(meetingType: "sales", from: sessions)
        XCTAssertEqual(suggested, "assertive")
    }

    func testSuggestedStyleIgnoresDifferentMeetingType() {
        let sessions = [
            makeSession(meetingType: "interview", preferredAnswerStyle: "safe"),
            makeSession(meetingType: "interview", preferredAnswerStyle: "safe"),
        ]
        let suggested = CrossSessionMemoryBuilder().suggestedAnswerStyle(meetingType: "sales", from: sessions)
        XCTAssertNil(suggested)
    }

    func testMeetingConfigurationPreferredAnswerStyleDecodesWithDefault() throws {
        let json = """
        {"speakerName":"Alice","meetingType":"sales","userLevel":"beginner","tone":"confident","length":"short","creativity":"balanced","aiMode":"active"}
        """
        let config = try JSONDecoder().decode(MeetingConfiguration.self, from: Data(json.utf8))
        XCTAssertEqual(config.preferredAnswerStyle, "")
    }
}
