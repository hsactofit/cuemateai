import Foundation

/// Structured outcome for a completed session (CM-BLG-082).
/// Auto-detected from summary signals; can be manually overridden.
enum SessionOutcome: String, Codable, Sendable, CaseIterable, Equatable {
    case pilot
    case followUp = "follow-up"
    case blocked
    case internalAction = "internal-action"
    case openRisk = "open-risk"
    case unclear

    var title: String {
        switch self {
        case .pilot:          "Pilot"
        case .followUp:       "Follow-up"
        case .blocked:        "Blocked"
        case .internalAction: "Internal Action"
        case .openRisk:       "Open Risk"
        case .unclear:        "Unclear"
        }
    }

    var statusColor: String {
        switch self {
        case .pilot:          "green"
        case .followUp:       "blue"
        case .blocked:        "red"
        case .internalAction: "orange"
        case .openRisk:       "yellow"
        case .unclear:        "gray"
        }
    }
}

extension SessionOutcome {
    /// Infers the most likely outcome from a meeting summary using keyword signals.
    static func detect(from summary: MeetingSummary?) -> SessionOutcome {
        guard let summary else { return .unclear }
        let combined = [
            summary.outcomeNote,
            summary.decisionSummary,
            summary.overview,
            summary.keyTopics.joined(separator: " "),
            summary.actionItems.joined(separator: " "),
        ].joined(separator: " ").lowercased()

        if combined.contains("pilot") || combined.contains("trial") || combined.contains("proof of concept") || combined.contains("poc") {
            return .pilot
        }
        if combined.contains("blocked") || combined.contains("no decision") || combined.contains("stalled") || combined.contains("waiting on") {
            return .blocked
        }
        if combined.contains("follow up") || combined.contains("follow-up") || combined.contains("next call") || combined.contains("next meeting") || combined.contains("circle back") {
            return .followUp
        }
        if combined.contains("open risk") || combined.contains("unresolved risk") || combined.contains("risk remains") {
            return .openRisk
        }
        if combined.contains("internal action") || combined.contains("assigned to") || combined.contains("action owner") || combined.contains("internal task") {
            return .internalAction
        }
        return .unclear
    }
}

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
    /// Structured outcome for this session. Auto-detected from summary; can be manually overridden.
    /// Nil for sessions created before this field was added.
    var sessionOutcome: SessionOutcome?

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
        followUpArtifact: StoredFollowUpArtifact?,
        sessionOutcome: SessionOutcome? = nil
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
        self.sessionOutcome = sessionOutcome
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
        sessionOutcome = try? c.decodeIfPresent(SessionOutcome.self, forKey: .sessionOutcome) ?? nil
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
