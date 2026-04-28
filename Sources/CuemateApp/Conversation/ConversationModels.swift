import Foundation

struct ConversationRequest: Sendable {
    let configuration: MeetingConfiguration
    let transcriptSegments: [TranscriptSegment]
    let retrievalResults: [RetrievalSearchResult]
    let userDisplayName: String
    let collaboratorRoleLabel: String
    /// The most recent final segment from the other speaker — the statement/question being responded to.
    let latestQuestion: TranscriptSegment?
    /// Detected intent for the current moment (e.g. "pricing", "objection", "decision", "nextStep", "general").
    let detectedIntent: String
}

struct ConversationResponse: Sendable {
    let primary: String
    let why: String
    let next: String
    let modeLabel: String
}

struct ConversationResponsePayload: Codable {
    let primary: String
    let why: String
    let next: String
}
