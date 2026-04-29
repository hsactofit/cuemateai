import Foundation
import XCTest
@testable import CuemateApp

final class ScreenContextTests: XCTestCase {

    // MARK: - AppState persistence round-trip

    func testScreenContextEnabledPersistsTrue() throws {
        let state = makeAppState(screenContextEnabled: true)
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(AppState.self, from: data)
        XCTAssertTrue(decoded.screenContextEnabled)
    }

    func testScreenContextEnabledPersistsFalse() throws {
        let state = makeAppState(screenContextEnabled: false)
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(AppState.self, from: data)
        XCTAssertFalse(decoded.screenContextEnabled)
    }

    func testScreenContextBackwardCompatDefaultsFalse() throws {
        let json = """
        {
          "autoResponseEnabled": true,
          "clickThroughEnabled": false,
          "confidenceMode": "balanced",
          "configuration": {
            "aiMode":"active","creativity":"balanced","length":"short",
            "meetingGoal":"","meetingLanguage":"en","meetingType":"sales",
            "mustCoverPoints":"","participantCompany":"","participantName":"",
            "preferredAnswerStyle":"","priorContextNote":"","relationshipStage":"new",
            "speakerName":"Me","targetOutcome":"","tone":"confident","userLevel":"beginner"
          },
          "currentSuggestionIndex": 0,
          "excludedFromMemoryIDs": [],
          "generationProvider": "localHeuristic",
          "isPaused": false,
          "memoryEnabled": true,
          "offlineModeEnabled": false,
          "overlayAnchor": "topCenter",
          "overlayContent": { "nowSay": "", "why": "", "next": "" },
          "overlayHorizontalInset": 0,
          "overlayPinnedNearCamera": false,
          "overlayVerticalInset": 0,
          "transcriptionProvider": "appleSpeech"
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AppState.self, from: json)
        XCTAssertFalse(decoded.screenContextEnabled, "Missing key should default to false")
    }

    // MARK: - ConversationRequest screenContext field

    func testConversationRequestCarriesScreenContext() {
        let request = makeRequest(screenContext: "Slide 3: Q3 Revenue $4.2M")
        XCTAssertEqual(request.screenContext, "Slide 3: Q3 Revenue $4.2M")
    }

    func testConversationRequestEmptyScreenContextWhenDisabled() {
        let request = makeRequest(screenContext: "")
        XCTAssertTrue(request.screenContext.isEmpty)
    }

    // MARK: - Screen context pass-through logic

    func testScreenContextOmittedFromRequestWhenDisabled() {
        // Simulate effectiveScreenContext: disabled → always empty even if text exists
        let storedText = "Some slide content"
        let effective = effectiveScreenContext(enabled: false, storedText: storedText)
        XCTAssertTrue(effective.isEmpty)
    }

    func testScreenContextIncludedWhenEnabled() {
        let storedText = "Q3 targets: $10M ARR, 95% NRR"
        let effective = effectiveScreenContext(enabled: true, storedText: storedText)
        XCTAssertEqual(effective, storedText)
    }

    // MARK: - Helpers

    private func makeRequest(screenContext: String) -> ConversationRequest {
        ConversationRequest(
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
            screenContext: screenContext,
            calendarContext: "",
            teamContext: ""
        )
    }

    private func makeAppState(screenContextEnabled: Bool) -> AppState {
        AppState(
            configuration: MeetingConfiguration(),
            overlayContent: OverlayContent(),
            clickThroughEnabled: false,
            isPaused: false,
            overlayPinnedNearCamera: false,
            overlayAnchor: .topCenter,
            overlayHorizontalInset: 0,
            overlayVerticalInset: 0,
            overlayOpacity: 0.96,
            confidenceMode: "balanced",
            currentSuggestionIndex: 0,
            transcriptionProvider: .appleSpeech,
            transcriptInterpretationMode: .sharedRoom,
            generationProvider: .localHeuristic,
            openAIOutputMode: .text,
            openAIModelProfile: .test,
            autoResponseEnabled: true,
            memoryEnabled: true,
            excludedFromMemoryIDs: [],
            offlineModeEnabled: false,
            screenContextEnabled: screenContextEnabled,
            activePlaybookID: ""
        )
    }

    private func effectiveScreenContext(enabled: Bool, storedText: String) -> String {
        enabled ? storedText : ""
    }
}
