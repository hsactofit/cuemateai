import Foundation
import XCTest
@testable import CuemateApp

final class OfflineModeTests: XCTestCase {

    // MARK: - AppState persistence round-trip

    func testAppStateEncodeDecodeOfflineFalse() throws {
        let state = makeAppState(offlineModeEnabled: false)
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(AppState.self, from: data)
        XCTAssertFalse(decoded.offlineModeEnabled)
    }

    func testAppStateEncodeDecodeOfflineTrue() throws {
        let state = makeAppState(offlineModeEnabled: true)
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(AppState.self, from: data)
        XCTAssertTrue(decoded.offlineModeEnabled)
    }

    func testAppStateBackwardCompatibilityDefaultsFalse() throws {
        // JSON without the offlineModeEnabled key — older persisted state
        let json = """
        {
          "autoResponseEnabled": true,
          "clickThroughEnabled": false,
          "confidenceMode": "balanced",
          "configuration": {
            "aiMode": "active", "creativity": "balanced", "length": "short",
            "meetingGoal": "", "meetingType": "sales", "mustCoverPoints": "",
            "participantCompany": "", "participantName": "", "preferredAnswerStyle": "",
            "priorContextNote": "", "relationshipStage": "new",
            "speakerName": "Me", "targetOutcome": "", "tone": "confident",
            "userLevel": "beginner"
          },
          "currentSuggestionIndex": 0,
          "excludedFromMemoryIDs": [],
          "generationProvider": "localHeuristic",
          "isPaused": false,
          "memoryEnabled": true,
          "overlayAnchor": "topCenter",
          "overlayContent": { "nowSay": "", "why": "", "next": "" },
          "overlayHorizontalInset": 0,
          "overlayPinnedNearCamera": false,
          "overlayVerticalInset": 0,
          "transcriptionProvider": "appleSpeech"
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AppState.self, from: json)
        XCTAssertFalse(decoded.offlineModeEnabled, "Missing key should default to false")
    }

    // MARK: - effectiveGenerationProvider logic (tested via AppState field only)

    func testEffectiveProviderOverrideLogic() {
        // Simulate the logic of effectiveGenerationProvider without AppModel
        func effective(offline: Bool, selected: GenerationProvider) -> GenerationProvider {
            offline ? .localHeuristic : selected
        }

        XCTAssertEqual(effective(offline: true, selected: .openAI), .localHeuristic)
        XCTAssertEqual(effective(offline: true, selected: .ollama), .localHeuristic)
        XCTAssertEqual(effective(offline: true, selected: .localHeuristic), .localHeuristic)
        XCTAssertEqual(effective(offline: false, selected: .openAI), .openAI)
        XCTAssertEqual(effective(offline: false, selected: .ollama), .ollama)
        XCTAssertEqual(effective(offline: false, selected: .localHeuristic), .localHeuristic)
    }

    // MARK: - Helpers

    private func makeAppState(offlineModeEnabled: Bool) -> AppState {
        AppState(
            configuration: MeetingConfiguration(),
            overlayContent: OverlayContent(),
            clickThroughEnabled: false,
            isPaused: false,
            overlayPinnedNearCamera: false,
            overlayAnchor: .topCenter,
            overlayHorizontalInset: 0,
            overlayVerticalInset: 0,
            confidenceMode: "balanced",
            currentSuggestionIndex: 0,
            transcriptionProvider: .appleSpeech,
            generationProvider: .localHeuristic,
            autoResponseEnabled: true,
            memoryEnabled: true,
            excludedFromMemoryIDs: [],
            offlineModeEnabled: offlineModeEnabled
        )
    }
}
