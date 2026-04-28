import Foundation
import XCTest
@testable import CuemateApp

final class MultilingualTests: XCTestCase {

    // MARK: - MeetingLanguage enum

    func testAllCasesHaveTitle() {
        for lang in MeetingLanguage.allCases {
            XCTAssertFalse(lang.title.isEmpty, "\(lang.rawValue) title should not be empty")
        }
    }

    func testAllCasesHaveAppleSpeechLocale() {
        for lang in MeetingLanguage.allCases {
            let locale = lang.appleSpeechLocale
            XCTAssertFalse(locale.identifier.isEmpty, "\(lang.rawValue) appleSpeechLocale should be non-empty")
        }
    }

    func testEnglishLocale() {
        XCTAssertEqual(MeetingLanguage.english.appleSpeechLocale.identifier, "en-US")
    }

    func testAutoDetectFallsBackToEnglishLocale() {
        XCTAssertEqual(MeetingLanguage.autoDetect.appleSpeechLocale.identifier, "en-US")
    }

    func testSpanishLocale() {
        XCTAssertEqual(MeetingLanguage.spanish.appleSpeechLocale.identifier, "es-ES")
    }

    func testWhisperCodeMatchesRawValue() {
        for lang in MeetingLanguage.allCases {
            XCTAssertEqual(lang.whisperCode, lang.rawValue)
        }
    }

    // MARK: - MeetingConfiguration Codable round-trip

    func testMeetingLanguagePersistsAndRestores() throws {
        var config = MeetingConfiguration()
        config.meetingLanguage = MeetingLanguage.french.rawValue
        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(MeetingConfiguration.self, from: data)
        XCTAssertEqual(decoded.meetingLanguage, "fr")
    }

    func testMeetingLanguageBackwardCompatDefaultsToEnglish() throws {
        // Old persisted JSON without meetingLanguage key
        let json = """
        {
          "speakerName":"Me","meetingType":"sales","userLevel":"beginner",
          "tone":"confident","length":"short","creativity":"balanced","aiMode":"active",
          "participantName":"","participantCompany":"","relationshipStage":"new",
          "priorContextNote":"","meetingGoal":"","targetOutcome":"","mustCoverPoints":"",
          "preferredAnswerStyle":""
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MeetingConfiguration.self, from: json)
        XCTAssertEqual(decoded.meetingLanguage, "en", "Missing key should default to English")
    }

    // MARK: - ConversationRequest meetingLanguage field

    func testConversationRequestCarriesLanguage() {
        let config = makeMeetingConfig(language: "es")
        let request = ConversationRequest(
            configuration: config,
            transcriptSegments: [],
            retrievalResults: [],
            userDisplayName: "Me",
            collaboratorRoleLabel: "Them",
            latestQuestion: nil,
            detectedIntent: "general",
            crossSessionMemory: "",
            meetingLanguage: config.meetingLanguage,
            screenContext: "",
            calendarContext: "",
            teamContext: ""
        )
        XCTAssertEqual(request.meetingLanguage, "es")
    }

    // MARK: - Helpers

    private func makeMeetingConfig(language: String) -> MeetingConfiguration {
        var config = MeetingConfiguration()
        config.meetingLanguage = language
        return config
    }
}
