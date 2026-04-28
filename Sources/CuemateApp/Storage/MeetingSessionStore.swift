import Foundation

struct MeetingSessionStore: Sendable {
    let appPaths: AppPaths

    private var sessionsURL: URL {
        appPaths.sessionsDirectory.appendingPathComponent("meeting-sessions.json")
    }

    func loadSessions() throws -> [MeetingSessionRecord] {
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try Data(contentsOf: sessionsURL)
        return try decoder.decode(MeetingSessionLibrary.self, from: data).sessions
    }

    /// Non-throwing variant — returns an empty array on any read or decode error.
    /// Use this at app startup and in the history coordinator so a corrupt store
    /// does not crash the app; the bad data stays on disk for manual recovery.
    func loadSessionsSafely() -> [MeetingSessionRecord] {
        (try? loadSessions()) ?? []
    }

    func saveSessions(_ sessions: [MeetingSessionRecord]) throws {
        // Ensure the parent directory exists before writing (handles first-run).
        let dir = sessionsURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(MeetingSessionLibrary(sessions: sessions))
        try data.write(to: sessionsURL, options: [.atomic])
    }

    // MARK: - Targeted field updates

    /// Persists a pre-meeting brief onto an existing session record.
    /// No-ops silently if the session ID is not found.
    func saveBrief(_ brief: MeetingBrief, forSessionID id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].brief = brief
        try saveSessions(sessions)
    }

    /// Persists a follow-up artifact onto an existing session record.
    /// No-ops silently if the session ID is not found.
    func saveFollowUpArtifact(_ artifact: StoredFollowUpArtifact, forSessionID id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].followUpArtifact = artifact
        try saveSessions(sessions)
    }

    /// Persists a summary result (both `MeetingSummary` and `StoredFollowUpArtifact`) in one write.
    /// Avoids two separate load-modify-save cycles when both fields need updating together.
    func saveSummaryResult(_ result: SummaryResult, diagnostics: SessionDiagnostics, forSessionID id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].summary = result.summary
        sessions[index].followUpArtifact = result.followUpArtifact
        sessions[index].diagnostics = diagnostics
        sessions[index].sessionOutcome = SessionOutcome.detect(from: result.summary)
        try saveSessions(sessions)
    }

    /// Saves a manually-chosen session outcome, overriding the auto-detected one.
    func saveSessionOutcome(_ outcome: SessionOutcome, forSessionID id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].sessionOutcome = outcome
        try saveSessions(sessions)
    }

    // MARK: - Session lifecycle

    /// Loads a single session by ID. Returns nil if not found.
    func loadSession(id: UUID) throws -> MeetingSessionRecord? {
        try loadSessions().first { $0.id == id }
    }

    /// Appends a new session record to the store.
    func createSession(_ session: MeetingSessionRecord) throws {
        var sessions = try loadSessions()
        sessions.append(session)
        try saveSessions(sessions)
    }

    /// Sets `endedAt` on the session with the given ID.
    /// No-ops silently if the session ID is not found.
    func endSession(id: UUID, at date: Date = Date()) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].endedAt = date
        try saveSessions(sessions)
    }

    /// Updates the title on an existing session record.
    /// No-ops silently if the session ID is not found.
    func updateTitle(_ title: String, forSessionID id: UUID) throws {
        var sessions = try loadSessions()
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].title = title
        try saveSessions(sessions)
    }
}
