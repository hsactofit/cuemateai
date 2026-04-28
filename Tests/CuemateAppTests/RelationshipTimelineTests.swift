import Foundation
import XCTest
@testable import CuemateApp

final class RelationshipTimelineTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(
        participantName: String = "",
        participantCompany: String = "",
        meetingType: String = "sales",
        keyTopics: [String] = [],
        outcome: SessionOutcome? = nil,
        isActive: Bool = false,
        daysAgo: Double = 1
    ) -> MeetingSessionRecord {
        var config = MeetingConfiguration()
        config.participantName = participantName
        config.participantCompany = participantCompany
        config.meetingType = meetingType

        let summary = keyTopics.isEmpty ? nil : MeetingSummary(
            overview: "",
            keyTopics: keyTopics,
            actionItems: [],
            outcomeNote: "",
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )

        return MeetingSessionRecord(
            id: UUID(),
            title: "Test",
            startedAt: Date(timeIntervalSinceNow: -(daysAgo * 86400 + 3600)),
            endedAt: isActive ? nil : Date(timeIntervalSinceNow: -(daysAgo * 86400)),
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

    // MARK: - CM-BLG-092

    func testEmptyResultWhenNoNamedParticipants() {
        let sessions = [
            makeSession(participantName: ""),
            makeSession(participantName: ""),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        XCTAssertTrue(result.isEmpty)
    }

    func testActiveSessionsAreExcluded() {
        let active = makeSession(participantName: "Sarah", isActive: true)
        let completed = makeSession(participantName: "Sarah")
        let result = RelationshipTimelineBuilder().build(from: [active, completed])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].sessionCount, 1)
    }

    func testSessionsGroupedBySameParticipant() {
        let sessions = [
            makeSession(participantName: "Sarah", participantCompany: "Acme"),
            makeSession(participantName: "Sarah", participantCompany: "Acme"),
            makeSession(participantName: "Bob"),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        XCTAssertEqual(result.count, 2)
        let sarah = result.first { $0.displayName == "Sarah" }
        XCTAssertEqual(sarah?.sessionCount, 2)
        XCTAssertEqual(sarah?.company, "Acme")
    }

    func testSortedByMostRecentContact() {
        let older = makeSession(participantName: "Alice", daysAgo: 10)
        let newer = makeSession(participantName: "Bob", daysAgo: 1)
        let result = RelationshipTimelineBuilder().build(from: [older, newer])
        XCTAssertEqual(result[0].displayName, "Bob")
        XCTAssertEqual(result[1].displayName, "Alice")
    }

    func testMostRecentOutcomeIsFromLatestSession() {
        let older = makeSession(participantName: "Sarah", outcome: .blocked, daysAgo: 5)
        let newer = makeSession(participantName: "Sarah", outcome: .pilot, daysAgo: 1)
        let result = RelationshipTimelineBuilder().build(from: [older, newer])
        XCTAssertEqual(result[0].mostRecentOutcome, .pilot)
    }

    func testAllOutcomesCollected() {
        let sessions = [
            makeSession(participantName: "Sarah", outcome: .pilot),
            makeSession(participantName: "Sarah", outcome: .followUp),
            makeSession(participantName: "Sarah", outcome: .pilot),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        XCTAssertEqual(result[0].allOutcomes.count, 3)
    }

    func testRecurringTopicsRankedByFrequency() {
        let sessions = [
            makeSession(participantName: "Sarah", keyTopics: ["budget", "timeline"]),
            makeSession(participantName: "Sarah", keyTopics: ["budget", "integration"]),
            makeSession(participantName: "Sarah", keyTopics: ["integration"]),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        let topics = result[0].recurringTopics
        XCTAssertTrue(topics.prefix(2).contains("budget"), "budget should rank high")
        XCTAssertTrue(topics.prefix(2).contains("integration"), "integration should rank high")
    }

    func testDifferentCompanyTreatedAsDifferentContact() {
        let sessions = [
            makeSession(participantName: "Sarah", participantCompany: "Acme"),
            makeSession(participantName: "Sarah", participantCompany: "Beta Corp"),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        XCTAssertEqual(result.count, 2)
    }

    func testSameNameNoCompanyGroupedTogether() {
        let sessions = [
            makeSession(participantName: "Alex", participantCompany: ""),
            makeSession(participantName: "Alex", participantCompany: ""),
        ]
        let result = RelationshipTimelineBuilder().build(from: sessions)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].sessionCount, 2)
    }
}
