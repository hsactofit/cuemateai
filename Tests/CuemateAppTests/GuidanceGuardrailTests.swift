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

    private func makeRequest(
        userDisplay: String = "Alice",
        collaborator: String = "Prospect",
        segments: [TranscriptSegment] = [],
        latestQ: TranscriptSegment? = nil,
        intent: String = "general",
        memory: String = ""
    ) -> ConversationRequest {
        ConversationRequest(
            configuration: MeetingConfiguration(),
            transcriptSegments: segments,
            retrievalResults: [],
            userDisplayName: userDisplay,
            collaboratorRoleLabel: collaborator,
            sharedTranscriptMode: false,
            latestQuestion: latestQ,
            detectedIntent: intent,
            crossSessionMemory: memory,
            meetingLanguage: "en",
            screenContext: "",
            calendarContext: "",
            teamContext: ""
        )
    }

    func testConversationRequestCarriesRoleLabels() {
        let request = makeRequest(userDisplay: "Alice", collaborator: "Prospect")
        XCTAssertEqual(request.userDisplayName, "Alice")
        XCTAssertEqual(request.collaboratorRoleLabel, "Prospect")
        XCTAssertNil(request.latestQuestion)
        XCTAssertEqual(request.detectedIntent, "general")
        XCTAssertTrue(request.crossSessionMemory.isEmpty)
    }

    // MARK: - ConversationRequest context window (CM-BLG-033)

    func testConversationRequestLatestQuestionPointsToOtherSpeaker() {
        let userSeg = makeSegment(text: "We have strong ROI data.", speaker: "Alice")
        let otherSeg = makeSegment(text: "What is the timeline?", speaker: "Prospect")
        let request = makeRequest(
            segments: [otherSeg, userSeg],
            latestQ: otherSeg,
            intent: "nextStep"
        )
        XCTAssertEqual(request.latestQuestion?.text, "What is the timeline?")
        XCTAssertEqual(request.transcriptSegments.count, 2)
        XCTAssertEqual(request.detectedIntent, "nextStep")
    }

    func testConversationRequestWithNoOtherSpeakerHasNilLatestQuestion() {
        let userSeg = makeSegment(text: "Let me walk you through the demo.", speaker: "Alice")
        let request = makeRequest(segments: [userSeg])
        XCTAssertNil(request.latestQuestion)
    }

    func testConversationRequestCrossSessionMemoryPassThrough() {
        let memoryNote = "Prior history (Sarah): 2 sessions\nLast outcome: Pilot"
        let request = makeRequest(memory: memoryNote)
        XCTAssertEqual(request.crossSessionMemory, memoryNote)
    }

    // MARK: - MeetingConfiguration backward compat (CM-BLG-061)

    func testMeetingConfigurationDecodesLegacyJsonWithoutContactFields() throws {
        let json = """
        {"speakerName":"Alice","meetingType":"sales","userLevel":"beginner","tone":"confident","length":"short","creativity":"balanced","aiMode":"active"}
        """
        let config = try JSONDecoder().decode(MeetingConfiguration.self, from: Data(json.utf8))
        XCTAssertEqual(config.speakerName, "Alice")
        XCTAssertEqual(config.meetingCaptureMode, "remote")
        XCTAssertEqual(config.participantName, "")
        XCTAssertEqual(config.participantCompany, "")
        XCTAssertEqual(config.relationshipStage, "new")
        XCTAssertEqual(config.priorContextNote, "")
    }

    func testTranscriptSanitizerDropsBlankAudioMarker() {
        XCTAssertNil(TranscriptSanitizer.normalizedText("[BLANK_AUDIO]"))
        XCTAssertNil(TranscriptSanitizer.normalizedText("[BLANK_AUDO]"))
    }

    func testTranscriptSanitizerCollapsesWhitespace() {
        XCTAssertEqual(
            TranscriptSanitizer.normalizedText("  what   is \n the timeline? "),
            "what is the timeline?"
        )
    }

    func testParticipantContextLineWithFullContext() {
        let helper = MeetingModePromptHelper()
        var config = MeetingConfiguration()
        config.participantName = "Sarah"
        config.participantCompany = "Acme Corp"
        config.relationshipStage = "strategic"
        config.priorContextNote = "They stalled on budget last quarter"
        let line = helper.participantContextLine(for: config)
        XCTAssertTrue(line.contains("Sarah"))
        XCTAssertTrue(line.contains("Acme Corp"))
        XCTAssertTrue(line.contains("strategic"))
        XCTAssertTrue(line.contains("stalled on budget"))
    }

    func testParticipantContextLineWithNoContext() {
        let helper = MeetingModePromptHelper()
        let config = MeetingConfiguration()
        let line = helper.participantContextLine(for: config)
        XCTAssertFalse(line.isEmpty)
        XCTAssertTrue(line.contains("new contact"))
    }

    // MARK: - SessionOutcome detection (CM-BLG-082)

    func testOutcomeDetectsPilotFromSummary() {
        let summary = MeetingSummary(
            overview: "Agreed to run a pilot next quarter.",
            keyTopics: ["pilot", "timeline"],
            actionItems: [],
            outcomeNote: "Pilot approved.",
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )
        XCTAssertEqual(SessionOutcome.detect(from: summary), .pilot)
    }

    func testOutcomeDetectsFollowUpFromSummary() {
        let summary = MeetingSummary(
            overview: "Good discussion.",
            keyTopics: [],
            actionItems: ["Follow up next week"],
            outcomeNote: "Will circle back after internal review.",
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )
        XCTAssertEqual(SessionOutcome.detect(from: summary), .followUp)
    }

    func testOutcomeDetectsBlockedFromSummary() {
        let summary = MeetingSummary(
            overview: "No decision reached.",
            keyTopics: [],
            actionItems: [],
            outcomeNote: "Blocked — waiting on legal approval.",
            followUpDraft: "",
            followUpSubject: "",
            decisionSummary: ""
        )
        XCTAssertEqual(SessionOutcome.detect(from: summary), .blocked)
    }

    func testOutcomeIsUnclearWhenSummaryIsNil() {
        XCTAssertEqual(SessionOutcome.detect(from: nil), .unclear)
    }

    // MARK: - MeetingModePromptHelper specialization (CM-BLG-041, CM-BLG-043)

    func testSalesObjctionIntentIncludesReverseRisk() {
        let helper = MeetingModePromptHelper()
        let section = helper.systemPromptSection(for: "sales", intent: "objection")
        XCTAssertTrue(section.contains("reversible") || section.contains("low-risk"),
                      "Sales objection guidance should mention a low-risk or reversible next step")
    }

    func testSalesPricingIntentMentionsPilot() {
        let helper = MeetingModePromptHelper()
        let section = helper.systemPromptSection(for: "sales", intent: "pricing")
        XCTAssertTrue(section.lowercased().contains("pilot") || section.lowercased().contains("scope"),
                      "Sales pricing guidance should mention pilot or scope")
    }

    func testInterviewModeIncludesOutcomeFraming() {
        let helper = MeetingModePromptHelper()
        let section = helper.systemPromptSection(for: "interview", intent: "proof")
        XCTAssertTrue(section.lowercased().contains("outcome") || section.lowercased().contains("result"),
                      "Interview proof guidance should mention outcome or result")
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
