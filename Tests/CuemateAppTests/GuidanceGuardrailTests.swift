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
