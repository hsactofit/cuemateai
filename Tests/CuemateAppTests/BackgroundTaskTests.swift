import Foundation
import XCTest
@testable import CuemateApp

final class BackgroundTaskTests: XCTestCase {

    // MARK: - Helpers

    private func makeSession(
        actionItems: [String] = [],
        followUpNotes: String = "",
        daysAgo: Double = 1,
        isActive: Bool = false
    ) -> MeetingSessionRecord {
        let summary = actionItems.isEmpty ? nil : MeetingSummary(
            overview: "Test session.",
            keyTopics: [],
            actionItems: actionItems,
            outcomeNote: "",
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )
        return MeetingSessionRecord(
            id: UUID(),
            title: "Test Session",
            startedAt: Date(timeIntervalSinceNow: -(daysAgo * 86400 + 3600)),
            endedAt: isActive ? nil : Date(timeIntervalSinceNow: -(daysAgo * 86400)),
            configuration: MeetingConfiguration(),
            transcriptSegments: [],
            guidanceHistory: [],
            documentIDs: [],
            diagnostics: SessionDiagnostics(),
            summary: summary,
            followUpNotes: followUpNotes,
            brief: nil,
            followUpArtifact: nil,
            sessionOutcome: nil
        )
    }

    private func pendingFrom(_ sessions: [MeetingSessionRecord]) -> [MeetingSessionRecord] {
        let cutoff = Date(timeIntervalSinceNow: -30 * 86400)
        return sessions.filter { session in
            guard !session.isActive,
                  let endedAt = session.endedAt,
                  endedAt > cutoff,
                  session.followUpNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let items = session.summary?.actionItems,
                  !items.isEmpty
            else { return false }
            return true
        }
        .sorted { ($0.endedAt ?? $0.startedAt) > ($1.endedAt ?? $1.startedAt) }
    }

    // MARK: - CM-BLG-110: Pending follow-up detection

    func testSessionWithActionItemsAndNoNotesIsPending() {
        let session = makeSession(actionItems: ["Send proposal"])
        let result = pendingFrom([session])
        XCTAssertEqual(result.count, 1)
    }

    func testSessionWithNotesIsNotPending() {
        let session = makeSession(actionItems: ["Send proposal"], followUpNotes: "Sent the email")
        let result = pendingFrom([session])
        XCTAssertTrue(result.isEmpty)
    }

    func testSessionWithNoActionItemsIsNotPending() {
        let session = makeSession(actionItems: [])
        let result = pendingFrom([session])
        XCTAssertTrue(result.isEmpty)
    }

    func testActiveSessionIsNotPending() {
        let session = makeSession(actionItems: ["Do something"], isActive: true)
        let result = pendingFrom([session])
        XCTAssertTrue(result.isEmpty)
    }

    func testOldSessionBeyond30DaysIsNotPending() {
        let session = makeSession(actionItems: ["Old task"], daysAgo: 31)
        let result = pendingFrom([session])
        XCTAssertTrue(result.isEmpty)
    }

    func testPendingSessionsSortedNewestFirst() {
        let older = makeSession(actionItems: ["Task A"], daysAgo: 5)
        let newer = makeSession(actionItems: ["Task B"], daysAgo: 1)
        let result = pendingFrom([older, newer])
        XCTAssertEqual(result.first?.summary?.actionItems.first, "Task B")
    }

    func testHandledSentinelNotesRemoveFromPending() {
        let session = makeSession(actionItems: ["Send proposal"], followUpNotes: "Handled")
        let result = pendingFrom([session])
        XCTAssertTrue(result.isEmpty)
    }

    func testWhitespaceOnlyNotesCountsAsEmpty() {
        let session = makeSession(actionItems: ["Call client"], followUpNotes: "   ")
        let result = pendingFrom([session])
        XCTAssertEqual(result.count, 1)
    }
}
