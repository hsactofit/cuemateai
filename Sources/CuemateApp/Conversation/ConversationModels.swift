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
    /// Cross-session memory note for recurring contacts or meeting types. Empty string when no history exists.
    let crossSessionMemory: String
    /// BCP-47 language code for the meeting (e.g. "en", "es", "fr"). Used to instruct AI providers to respond in that language.
    let meetingLanguage: String
    /// On-screen text captured via OCR. Empty string when screen context is disabled or unavailable.
    let screenContext: String
    /// Calendar event context imported from an ICS file. Empty string when no event is imported.
    let calendarContext: String
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
