import Foundation
import XCTest
@testable import CuemateApp

final class PlaybookTests: XCTestCase {

    // MARK: - Built-in defaults

    func testDefaultPlaybooksExistForAllModes() {
        let modes = ["sales", "demo", "client-review", "interview", "internal-sync"]
        for mode in modes {
            XCTAssertNotNil(
                MeetingPlaybook.defaults.first(where: { $0.meetingType == mode }),
                "No built-in playbook for \(mode)"
            )
        }
    }

    func testAllDefaultPlaybooksAreMarkedBuiltIn() {
        for pb in MeetingPlaybook.defaults {
            XCTAssertTrue(pb.isBuiltIn, "\(pb.name) should be marked isBuiltIn")
        }
    }

    func testDefaultPlaybooksHaveFocusAreas() {
        for pb in MeetingPlaybook.defaults {
            XCTAssertFalse(pb.focusAreas.isEmpty, "\(pb.name) should have at least one focus area")
        }
    }

    func testDefaultPlaybooksHaveCoachingCues() {
        for pb in MeetingPlaybook.defaults {
            XCTAssertFalse(pb.coachingCues.isEmpty, "\(pb.name) should have at least one coaching cue")
        }
    }

    func testDefaultPlaybooksHaveRiskSignals() {
        for pb in MeetingPlaybook.defaults {
            XCTAssertFalse(pb.riskSignals.isEmpty, "\(pb.name) should have at least one risk signal")
        }
    }

    // MARK: - PlaybookStore load/save round-trip

    func testPlaybookStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let paths = AppPaths(
            baseDirectory: dir, modelsDirectory: dir, documentsDirectory: dir,
            embeddingsDirectory: dir, logsDirectory: dir, configDirectory: dir,
            indexesDirectory: dir, sessionsDirectory: dir
        )
        let store = PlaybookStore(appPaths: paths)

        let custom = MeetingPlaybook(
            id: UUID(),
            name: "My Sales Pack",
            meetingType: "sales",
            focusAreas: ["Focus on ROI"],
            coachingCues: ["Always mention the pilot option"],
            riskSignals: ["Budget not yet confirmed"],
            teamContext: "We target mid-market SaaS companies with 50–200 seats.",
            isBuiltIn: false,
            createdAt: Date()
        )

        try store.save([custom])
        let loaded = store.load()

        // Built-ins are always prepended
        XCTAssertEqual(loaded.filter { !$0.isBuiltIn }.count, 1)
        let reloaded = loaded.first(where: { !$0.isBuiltIn })!
        XCTAssertEqual(reloaded.name, "My Sales Pack")
        XCTAssertEqual(reloaded.teamContext, "We target mid-market SaaS companies with 50–200 seats.")
    }

    func testBuiltInsNotWrittenToDisk() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let paths = AppPaths(
            baseDirectory: dir, modelsDirectory: dir, documentsDirectory: dir,
            embeddingsDirectory: dir, logsDirectory: dir, configDirectory: dir,
            indexesDirectory: dir, sessionsDirectory: dir
        )
        let store = PlaybookStore(appPaths: paths)

        // Save a mix — only custom should be written
        try store.save(MeetingPlaybook.defaults)

        let fileURL = dir.appendingPathComponent("playbooks.json")
        let data = try Data(contentsOf: fileURL)
        let decoded = try JSONDecoder().decode([MeetingPlaybook].self, from: data)
        XCTAssertTrue(decoded.isEmpty, "No built-ins should be written to disk")
    }

    // MARK: - Import / export

    func testImportResetsIDAndMarksCustom() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let paths = AppPaths(
            baseDirectory: dir, modelsDirectory: dir, documentsDirectory: dir,
            embeddingsDirectory: dir, logsDirectory: dir, configDirectory: dir,
            indexesDirectory: dir, sessionsDirectory: dir
        )
        let store = PlaybookStore(appPaths: paths)

        let original = MeetingPlaybook.defaults.first!
        let exportURL = try store.exportPlaybook(original, to: dir)
        let imported = try store.importPlaybook(from: exportURL)

        XCTAssertNotEqual(imported.id, original.id, "Imported playbook must get a new UUID")
        XCTAssertFalse(imported.isBuiltIn, "Imported playbook must be marked custom")
    }

    // MARK: - ConversationRequest teamContext field

    func testConversationRequestCarriesTeamContext() {
        let request = ConversationRequest(
            configuration: MeetingConfiguration(),
            transcriptSegments: [],
            retrievalResults: [],
            userDisplayName: "Me",
            collaboratorRoleLabel: "Them",
            latestQuestion: nil,
            detectedIntent: "general",
            crossSessionMemory: "",
            meetingLanguage: "en",
            screenContext: "",
            calendarContext: "",
            teamContext: "We focus on mid-market SaaS deals."
        )
        XCTAssertTrue(request.teamContext.contains("mid-market"))
    }
}
