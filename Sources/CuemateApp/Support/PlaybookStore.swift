import Foundation

// MARK: - Model

/// A reusable meeting playbook containing team-specific coaching cues, focus areas, and context.
/// Built-in playbooks cover the five core meeting modes and cannot be deleted.
/// Custom playbooks can be created, imported, exported, and deleted.
struct MeetingPlaybook: Codable, Sendable, Identifiable, Equatable {
    var id: UUID
    var name: String
    /// The meeting mode this playbook is designed for (matches MeetingConfiguration.meetingType).
    var meetingType: String
    /// Team-specific focus areas that augment or replace the mode defaults in briefs.
    var focusAreas: [String]
    /// Recurring coaching cues shown during live sessions when this playbook is active.
    var coachingCues: [String]
    /// Risk signals the team has learned to watch for in this meeting type.
    var riskSignals: [String]
    /// Free-form team context injected into every AI prompt while this playbook is active.
    /// Use this for competitive positioning, ICP notes, pricing rules, or team-specific norms.
    var teamContext: String
    var isBuiltIn: Bool
    var createdAt: Date

    // MARK: - Built-in defaults

    static var defaults: [MeetingPlaybook] {
        [
            MeetingPlaybook(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                name: "Sales Call — Default",
                meetingType: "sales",
                focusAreas: [
                    "Qualify budget authority and timeline before the pitch",
                    "Surface the business pain in their words, not yours",
                    "Anchor on the smallest concrete next step toward a pilot",
                    "Test commitment with a soft trial close before ending",
                ],
                coachingCues: [
                    "Ask one open question before explaining any feature",
                    "If budget comes up early, de-risk with a pilot framing",
                    "Name the next step explicitly and get verbal agreement",
                ],
                riskSignals: [
                    "Decision-maker not in the room",
                    "Procurement or legal mentioned as a gating step",
                    "Timeline is vague or keeps shifting",
                ],
                teamContext: "",
                isBuiltIn: true,
                createdAt: Date(timeIntervalSince1970: 0)
            ),
            MeetingPlaybook(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                name: "Demo — Default",
                meetingType: "demo",
                focusAreas: [
                    "Confirm the workflow they most want to see before screen-sharing",
                    "Map every feature shown to a workflow they described",
                    "Surface integration concerns early — do not save them for the end",
                    "Close with a clear 'what would you show your team?' question",
                ],
                coachingCues: [
                    "Lead with the outcome, not the feature",
                    "Pause and ask 'does that map to your workflow?' after each section",
                    "If they go quiet, ask what they are thinking — do not fill the silence",
                ],
                riskSignals: [
                    "No clear use-case confirmed before the demo starts",
                    "Audience is too broad — champion and skeptic in same room",
                    "Integration complexity surfaces mid-demo without context",
                ],
                teamContext: "",
                isBuiltIn: true,
                createdAt: Date(timeIntervalSince1970: 0)
            ),
            MeetingPlaybook(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                name: "Client Review — Default",
                meetingType: "client-review",
                focusAreas: [
                    "Open with concrete evidence of progress before raising risks",
                    "Name the top open risk and own it — do not wait for the client to find it",
                    "Close on one accountable action with a named owner and date",
                    "Keep the tone strategic — avoid becoming a status reporter",
                ],
                coachingCues: [
                    "Acknowledge delay or scope change before the client does",
                    "Use their language for success criteria, not ours",
                    "If the tone shifts, pause and ask 'what is most important to resolve today?'",
                ],
                riskSignals: [
                    "Client has been quiet between reviews — expectation drift likely",
                    "Scope or timeline has changed but not been formally acknowledged",
                    "No clear owner for the top open item from the last review",
                ],
                teamContext: "",
                isBuiltIn: true,
                createdAt: Date(timeIntervalSince1970: 0)
            ),
            MeetingPlaybook(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                name: "Interview — Default",
                meetingType: "interview",
                focusAreas: [
                    "Answer every question with one concrete example from past experience",
                    "Tie the example to a measurable outcome",
                    "Ask one clarifying question that shows you researched the role",
                    "Ask about the next step in their process before ending",
                ],
                coachingCues: [
                    "Situation → Action → Result — keep each story under 90 seconds",
                    "If unsure, say 'let me think about that for a moment' — do not rush",
                    "Mirror the interviewer's energy and pacing",
                ],
                riskSignals: [
                    "Answer is going too long — cut to the outcome",
                    "Question touched a gap in experience — address it directly, do not deflect",
                    "No follow-up question asked yet — losing engagement",
                ],
                teamContext: "",
                isBuiltIn: true,
                createdAt: Date(timeIntervalSince1970: 0)
            ),
            MeetingPlaybook(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                name: "Internal Sync — Default",
                meetingType: "internal-sync",
                focusAreas: [
                    "Name the one decision this sync must produce before diving into updates",
                    "Surface blockers early — do not save them for the end",
                    "Assign a named owner to every open item before closing",
                    "Keep updates short — focus time on the items that need a decision",
                ],
                coachingCues: [
                    "If the conversation drifts, redirect: 'what is blocking a decision here?'",
                    "Call out when a discussion needs a separate thread — do not resolve in the room",
                    "End with a read-back: decision, owner, deadline",
                ],
                riskSignals: [
                    "No decision reached — meeting becomes a status update only",
                    "Action item has no clear owner or deadline",
                    "Key stakeholder is missing from the room",
                ],
                teamContext: "",
                isBuiltIn: true,
                createdAt: Date(timeIntervalSince1970: 0)
            ),
        ]
    }
}

// MARK: - Store

/// Persists custom playbooks to `configDirectory/playbooks.json`.
/// Built-in defaults are merged on load — they are never written to disk.
struct PlaybookStore: Sendable {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(appPaths: AppPaths) {
        fileURL = appPaths.configDirectory.appendingPathComponent("playbooks.json")
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        encoder = enc
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        decoder = dec
    }

    /// Loads custom playbooks from disk and merges built-in defaults.
    /// Built-ins come first; custom playbooks follow in creation order.
    func load() -> [MeetingPlaybook] {
        var result = MeetingPlaybook.defaults
        guard let data = try? Data(contentsOf: fileURL),
              let custom = try? decoder.decode([MeetingPlaybook].self, from: data)
        else { return result }

        let builtInIDs = Set(result.map(\.id))
        result += custom.filter { !builtInIDs.contains($0.id) }
        return result
    }

    /// Persists only the non-built-in playbooks to disk.
    func save(_ playbooks: [MeetingPlaybook]) throws {
        let custom = playbooks.filter { !$0.isBuiltIn }
        let data = try encoder.encode(custom)
        try data.write(to: fileURL, options: [.atomic])
    }

    /// Decodes a single playbook from an exported JSON file.
    func importPlaybook(from url: URL) throws -> MeetingPlaybook {
        let data = try Data(contentsOf: url)
        var playbook = try decoder.decode(MeetingPlaybook.self, from: data)
        // Always assign a new ID and mark as custom on import.
        playbook.id = UUID()
        playbook.isBuiltIn = false
        playbook.createdAt = Date()
        return playbook
    }

    /// Writes a single playbook to a JSON file and returns the destination URL.
    func exportPlaybook(_ playbook: MeetingPlaybook, to directory: URL) throws -> URL {
        let safeName = playbook.name
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        let filename = "cuemate-playbook-\(safeName).json"
        let dest = directory.appendingPathComponent(filename)
        let data = try encoder.encode(playbook)
        try data.write(to: dest, options: [.atomic])
        return dest
    }
}
