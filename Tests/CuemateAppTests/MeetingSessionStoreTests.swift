import Foundation
import Testing
@testable import CuemateApp

struct MeetingSessionStoreTests {
    @Test
    func legacySessionDecodesWithDefaultDiagnostics() throws {
        let json = """
        {
          "sessions": [
            {
              "id": "11111111-1111-1111-1111-111111111111",
              "title": "Legacy Session",
              "startedAt": "2026-04-27T10:00:00Z",
              "endedAt": null,
              "configuration": {
                "speakerName": "Me",
                "meetingType": "sales",
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
        let session = try #require(library.sessions.first)

        #expect(session.title == "Legacy Session")
        #expect(session.diagnostics == SessionDiagnostics())
        #expect(session.followUpNotes == "")
        #expect(session.guidanceHistory.isEmpty)
        #expect(session.documentIDs.isEmpty)
    }

    @Test
    func saveSummaryResultPersistsDiagnostics() throws {
        let appPaths = makeTemporaryAppPaths()
        defer {
            try? FileManager.default.removeItem(at: appPaths.baseDirectory)
        }

        try appPaths.prepareDirectories()

        let store = MeetingSessionStore(appPaths: appPaths)
        let session = MeetingSessionRecord.makeNew(
            configuration: MeetingConfiguration(),
            title: "Diagnostics Session"
        )

        try store.createSession(session)

        let summary = MeetingSummary(
            overview: "Strong meeting with a clear next step.",
            keyTopics: ["pilot", "timeline"],
            actionItems: ["Send proposal"],
            outcomeNote: "Decision pending budget review.",
            followUpDraft: "Subject: Next steps\n\nThanks for the time.",
            followUpSubject: "Next steps",
            decisionSummary: "Budget review before kickoff."
        )
        let artifact = StoredFollowUpArtifact(
            subject: "Next steps",
            body: "Thanks for the time.",
            generatedAt: Date(timeIntervalSince1970: 1_746_000_000)
        )
        let result = SummaryResult(summary: summary, followUpArtifact: artifact)
        let diagnostics = SessionDiagnostics(
            recoveryEvents: 2,
            lowConfidenceEvents: 3,
            interruptionEvents: 1,
            providerFallbackEvents: 4
        )

        try store.saveSummaryResult(result, diagnostics: diagnostics, forSessionID: session.id)

        let loadedSession = try store.loadSession(id: session.id)
        let savedSession = try #require(loadedSession)
        #expect(savedSession.summary == summary)
        #expect(savedSession.followUpArtifact == artifact)
        #expect(savedSession.diagnostics == diagnostics)
        #expect(savedSession.endedAt == nil)
    }

    private func makeTemporaryAppPaths() -> AppPaths {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        return AppPaths(
            baseDirectory: base,
            modelsDirectory: base.appendingPathComponent("models", isDirectory: true),
            documentsDirectory: base.appendingPathComponent("documents", isDirectory: true),
            embeddingsDirectory: base.appendingPathComponent("embeddings", isDirectory: true),
            logsDirectory: base.appendingPathComponent("logs", isDirectory: true),
            configDirectory: base.appendingPathComponent("config", isDirectory: true),
            indexesDirectory: base.appendingPathComponent("indexes", isDirectory: true),
            sessionsDirectory: base.appendingPathComponent("sessions", isDirectory: true)
        )
    }
}
