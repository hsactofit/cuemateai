import Foundation
import XCTest
@testable import CuemateApp

final class GuidanceGuardrailTests: XCTestCase {

    // MARK: - Legacy decode (smoke)

    func testLegacySessionDecodesSafely() throws {
        let json = """
        {
          "sessions": [
            {
              "id": "22222222-2222-2222-2222-222222222222",
              "title": "Guardrail Session",
              "startedAt": "2026-04-28T08:00:00Z",
              "endedAt": null,
              "configuration": {
                "speakerName": "Me",
                "meetingType": "general",
                "userLevel": "beginner",
                "tone": "confident",
                "length": "short",
                "creativity": "balanced",
                "aiMode": "active"
              },
              "transcriptSegments": []
            }
          ]
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let library = try decoder.decode(MeetingSessionLibrary.self, from: Data(json.utf8))
        XCTAssertEqual(library.sessions.count, 1)
    }

    // MARK: - TranscriptSegment helpers

    private func makeSegment(text: String, confidence: Double = 0.95, isFinal: Bool = true, speaker: String = "Other") -> TranscriptSegment {
        TranscriptSegment(
            id: UUID(),
            speaker: speaker,
            text: text,
            confidence: confidence,
            isFinal: isFinal,
            createdAt: Date()
        )
    }

    // MARK: - ConversationRequest role labels (CM-BLG-031)

    func testConversationRequestCarriesRoleLabels() {
        let config = MeetingConfiguration()
        let request = ConversationRequest(
            configuration: config,
            transcriptSegments: [],
            retrievalResults: [],
            userDisplayName: "Alice",
            collaboratorRoleLabel: "Prospect",
            latestQuestion: nil
        )
        XCTAssertEqual(request.userDisplayName, "Alice")
        XCTAssertEqual(request.collaboratorRoleLabel, "Prospect")
        XCTAssertNil(request.latestQuestion)
    }

    // MARK: - ConversationRequest context window (CM-BLG-033)

    func testConversationRequestLatestQuestionPointsToOtherSpeaker() {
        let userSeg = makeSegment(text: "We have strong ROI data.", speaker: "Alice")
        let otherSeg = makeSegment(text: "What is the timeline?", speaker: "Prospect")
        let request = ConversationRequest(
            configuration: MeetingConfiguration(),
            transcriptSegments: [otherSeg, userSeg],
            retrievalResults: [],
            userDisplayName: "Alice",
            collaboratorRoleLabel: "Prospect",
            latestQuestion: otherSeg
        )
        XCTAssertEqual(request.latestQuestion?.text, "What is the timeline?")
        XCTAssertEqual(request.transcriptSegments.count, 2)
    }

    func testConversationRequestWithNoOtherSpeakerHasNilLatestQuestion() {
        let userSeg = makeSegment(text: "Let me walk you through the demo.", speaker: "Alice")
        let request = ConversationRequest(
            configuration: MeetingConfiguration(),
            transcriptSegments: [userSeg],
            retrievalResults: [],
            userDisplayName: "Alice",
            collaboratorRoleLabel: "Prospect",
            latestQuestion: nil
        )
        XCTAssertNil(request.latestQuestion)
    }

    // MARK: - SessionDiagnostics defaults

    func testSessionDiagnosticsDefaultsAreZero() {
        let d = SessionDiagnostics()
        XCTAssertEqual(d.recoveryEvents, 0)
        XCTAssertEqual(d.lowConfidenceEvents, 0)
        XCTAssertEqual(d.interruptionEvents, 0)
        XCTAssertEqual(d.providerFallbackEvents, 0)
    }

    func testSessionDiagnosticsEquality() {
        let a = SessionDiagnostics(recoveryEvents: 1, lowConfidenceEvents: 2, interruptionEvents: 0, providerFallbackEvents: 3)
        let b = SessionDiagnostics(recoveryEvents: 1, lowConfidenceEvents: 2, interruptionEvents: 0, providerFallbackEvents: 3)
        let c = SessionDiagnostics(recoveryEvents: 2, lowConfidenceEvents: 2, interruptionEvents: 0, providerFallbackEvents: 3)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    // MARK: - MeetingSessionRecord factory

    func testMakeNewSessionHasExpectedDefaults() {
        let config = MeetingConfiguration()
        let record = MeetingSessionRecord.makeNew(configuration: config, title: "Test")
        XCTAssertEqual(record.title, "Test")
        XCTAssertNil(record.endedAt)
        XCTAssertTrue(record.isActive)
        XCTAssertNil(record.summary)
        XCTAssertNil(record.brief)
    }
}
