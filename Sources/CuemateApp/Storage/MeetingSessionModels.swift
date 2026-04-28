import Foundation

/// A Codable follow-up artifact stored alongside a session record.
/// Optional field — old sessions decode it as nil without breaking.
struct StoredFollowUpArtifact: Codable, Sendable, Equatable {
    var subject: String
    var body: String
    var generatedAt: Date
}

struct GuidanceSnapshot: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let createdAt: Date
    let provider: String
    let retrievalQuery: String
    let sourceDocumentName: String?
    let content: OverlayContent
}

struct MeetingSessionRecord: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    var title: String
    let startedAt: Date
    var endedAt: Date?
    var configuration: MeetingConfiguration
    var transcriptSegments: [TranscriptSegment]
    var guidanceHistory: [GuidanceSnapshot]
    var documentIDs: [UUID]
    var diagnostics: SessionDiagnostics
    var summary: MeetingSummary?
    var followUpNotes: String
    /// Pre-meeting brief generated before the session starts.
    /// Nil for sessions created before this field was added.
    var brief: MeetingBrief?
    /// Stored follow-up artifact generated after the meeting ends.
    /// Nil for sessions created before this field was added.
    var followUpArtifact: StoredFollowUpArtifact?

    var isActive: Bool {
        endedAt == nil
    }

    // Explicit memberwise init — required because defining `init(from:)` suppresses synthesis.
    init(
        id: UUID,
        title: String,
        startedAt: Date,
        endedAt: Date?,
        configuration: MeetingConfiguration,
        transcriptSegments: [TranscriptSegment],
        guidanceHistory: [GuidanceSnapshot],
        documentIDs: [UUID],
        diagnostics: SessionDiagnostics,
        summary: MeetingSummary?,
        followUpNotes: String,
        brief: MeetingBrief?,
        followUpArtifact: StoredFollowUpArtifact?
    ) {
        self.id = id
        self.title = title
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.configuration = configuration
        self.transcriptSegments = transcriptSegments
        self.guidanceHistory = guidanceHistory
        self.documentIDs = documentIDs
        self.diagnostics = diagnostics
        self.summary = summary
        self.followUpNotes = followUpNotes
        self.brief = brief
        self.followUpArtifact = followUpArtifact
    }

    /// Custom decoder keeps old saved sessions decodable when new non-optional fields
    /// (e.g. `followUpNotes`) are added after sessions were already persisted.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        startedAt = try c.decode(Date.self, forKey: .startedAt)
        endedAt = try c.decodeIfPresent(Date.self, forKey: .endedAt)
        configuration = try c.decode(MeetingConfiguration.self, forKey: .configuration)
        transcriptSegments = try c.decode([TranscriptSegment].self, forKey: .transcriptSegments)
        guidanceHistory = (try? c.decode([GuidanceSnapshot].self, forKey: .guidanceHistory)) ?? []
        documentIDs = (try? c.decode([UUID].self, forKey: .documentIDs)) ?? []
        diagnostics = (try? c.decode(SessionDiagnostics.self, forKey: .diagnostics)) ?? SessionDiagnostics()
        summary = try? c.decodeIfPresent(MeetingSummary.self, forKey: .summary) ?? nil
        followUpNotes = (try? c.decode(String.self, forKey: .followUpNotes)) ?? ""
        brief = try? c.decodeIfPresent(MeetingBrief.self, forKey: .brief) ?? nil
        followUpArtifact = try? c.decodeIfPresent(StoredFollowUpArtifact.self, forKey: .followUpArtifact) ?? nil
    }
}

struct MeetingSessionLibrary: Codable, Sendable {
    var sessions: [MeetingSessionRecord]
}

// MARK: - Factory

extension MeetingSessionRecord {
    /// Creates a new session record ready to start.
    /// Sets `startedAt` to now; `endedAt` is nil until `endSession` is called.
    static func makeNew(
        configuration: MeetingConfiguration,
        title: String,
        documentIDs: [UUID] = []
    ) -> MeetingSessionRecord {
        MeetingSessionRecord(
            id: UUID(),
            title: title,
            startedAt: Date(),
            endedAt: nil,
            configuration: configuration,
            transcriptSegments: [],
            guidanceHistory: [],
            documentIDs: documentIDs,
            diagnostics: SessionDiagnostics(),
            summary: nil,
            followUpNotes: "",
            brief: nil,
            followUpArtifact: nil
        )
    }
}
