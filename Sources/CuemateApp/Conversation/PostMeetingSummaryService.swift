import Foundation

struct MeetingSummary: Codable, Sendable, Equatable {
    var overview: String
    var keyTopics: [String]
    var actionItems: [String]
    var outcomeNote: String
    var followUpDraft: String
    var decisionSummary: String
}

struct PostMeetingSummaryService: Sendable {
    func generateSummary(for session: MeetingSessionRecord, documents: [IngestedDocument]) -> MeetingSummary {
        let transcriptTexts = session.transcriptSegments
            .sorted { $0.createdAt < $1.createdAt }
            .map(\.text)

        let guidanceTexts = session.guidanceHistory
            .sorted { $0.createdAt < $1.createdAt }
            .map(\.content.nowSay)

        let mergedText = (transcriptTexts + guidanceTexts).joined(separator: " ")
        let summaryText = summarize(mergedText, wordLimit: 34)

        let keyTopics = extractKeyTopics(from: transcriptTexts + guidanceTexts)
        let actionItems = buildActionItems(from: session, documents: documents)
        let outcomeNote = deriveOutcome(from: session, transcriptTexts: transcriptTexts)
        let followUpDraft = buildFollowUpDraft(for: session, actionItems: actionItems, transcriptTexts: transcriptTexts)
        let decisionSummary = buildDecisionSummary(for: session, transcriptTexts: transcriptTexts)

        return MeetingSummary(
            overview: summaryText.isEmpty ? fallbackOverview(for: session) : summaryText,
            keyTopics: Array(keyTopics.prefix(4)),
            actionItems: Array(actionItems.prefix(4)),
            outcomeNote: outcomeNote,
            followUpDraft: followUpDraft,
            decisionSummary: decisionSummary
        )
    }

    private func extractKeyTopics(from texts: [String]) -> [String] {
        let interestingTokens = texts
            .flatMap { tokenize($0) }
            .filter { token in
                token.count > 4 && !stopWords.contains(token)
            }

        let ranked = Dictionary(interestingTokens.map { ($0, 1) }, uniquingKeysWith: +)
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .map(\.key)

        return ranked.map { $0.capitalized }
    }

    private func buildActionItems(from session: MeetingSessionRecord, documents: [IngestedDocument]) -> [String] {
        var items: [String] = []

        if let next = session.guidanceHistory.first?.content.next, !next.isEmpty {
            items.append(next)
        }

        if session.configuration.meetingType == "sales" {
            items.append("Follow up with the next concrete pilot or rollout step.")
        }

        if session.configuration.meetingType == "interview" {
            items.append("Prepare a sharper example for the topic that came up most.")
        }

        if !session.documentIDs.isEmpty {
            let attachedCount = documents.filter { session.documentIDs.contains($0.id) }.count
            items.append("Review the \(attachedCount) attached documents before the next meeting.")
        }

        if items.isEmpty {
            items.append("Review the meeting transcript and pick the next best follow-up.")
        }

        return deduplicated(items)
    }

    private func deriveOutcome(from session: MeetingSessionRecord, transcriptTexts: [String]) -> String {
        let transcript = transcriptTexts.joined(separator: " ").lowercased()
        if transcript.contains("pilot") || transcript.contains("next step") {
            return "The conversation pointed toward a concrete next-step discussion."
        }
        if transcript.contains("follow up") || transcript.contains("send") {
            return "A follow-up response or material handoff is likely needed."
        }
        if session.guidanceHistory.isEmpty {
            return "The session captured conversation context, but little guided output was recorded."
        }
        return "The session captured both conversation context and live guidance for later review."
    }

    private func fallbackOverview(for session: MeetingSessionRecord) -> String {
        "A \(session.configuration.meetingType) meeting with \(session.transcriptSegments.count) transcript items and \(session.guidanceHistory.count) guidance moments."
    }

    private func buildDecisionSummary(for session: MeetingSessionRecord, transcriptTexts: [String]) -> String {
        let transcript = transcriptTexts.joined(separator: " ").lowercased()

        if transcript.contains("pilot") {
            return "The conversation leaned toward a pilot-style next step."
        }
        if transcript.contains("follow up") || transcript.contains("send") {
            return "The meeting ended with a likely follow-up or material handoff."
        }
        if transcript.contains("timeline") || transcript.contains("next week") || transcript.contains("this week") {
            return "Timing and near-term execution looked important in the meeting."
        }

        switch session.configuration.meetingType {
        case "sales":
            return "The key outcome is whether this can move toward a qualified next step."
        case "demo":
            return "The key outcome is which workflow or product path should be shown next."
        case "client-review":
            return "The key outcome is progress clarity, open risk, and the next accountable step."
        case "interview":
            return "The key outcome is whether the discussion strengthened fit and created a clear next conversation."
        case "internal-sync":
            return "The key outcome is whether ownership and next action became clearer."
        default:
            return "The key outcome is the clearest next move coming out of the discussion."
        }
    }

    private func buildFollowUpDraft(
        for session: MeetingSessionRecord,
        actionItems: [String],
        transcriptTexts: [String]
    ) -> String {
        let subjectLine: String
        let opening: String

        switch session.configuration.meetingType {
        case "sales":
            subjectLine = "Subject: Next step from our conversation"
            opening = "Thanks again for the conversation today. Based on our discussion, the clearest next step is to keep the rollout focused and move with the smallest high-value starting point."
        case "demo":
            subjectLine = "Subject: Demo recap and next workflow"
            opening = "Thanks for the time today. Here is the short recap from the demo and the best next workflow to continue with."
        case "client-review":
            subjectLine = "Subject: Review recap and next actions"
            opening = "Thanks for the review today. Here is a concise recap of progress, the main open point, and the next action to keep things moving."
        case "interview":
            subjectLine = "Subject: Thank you and next steps"
            opening = "Thank you for the conversation today. I appreciated the chance to discuss the role and wanted to send a short follow-up with the clearest next step."
        case "internal-sync":
            subjectLine = "Subject: Sync recap and owners"
            opening = "Here is the short recap from the sync, along with the main decision path and next actions."
        default:
            subjectLine = "Subject: Meeting recap and next step"
            opening = "Thanks again for the conversation. Here is the short recap and the clearest next step from the meeting."
        }

        let topActions = actionItems.prefix(2).map { "- \($0)" }.joined(separator: "\n")
        let close = transcriptTexts.joined(separator: " ").lowercased().contains("send")
            ? "I will follow up with the requested material as the next step."
            : "Let me know if you want a shorter summary or a deeper follow-up from here."

        return """
        \(subjectLine)

        \(opening)

        Next actions:
        \(topActions.isEmpty ? "- Confirm the best next step from this meeting." : topActions)

        \(close)
        """
    }

    private func summarize(_ text: String, wordLimit: Int) -> String {
        text
            .split(whereSeparator: \.isWhitespace)
            .prefix(wordLimit)
            .joined(separator: " ")
    }

    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }

    private func deduplicated(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { value in
            seen.insert(value).inserted
        }
    }

    private let stopWords: Set<String> = [
        "about", "after", "again", "because", "before", "could", "there", "their",
        "would", "should", "while", "where", "which", "thanks", "based", "start",
        "still", "needs", "using", "local", "meeting", "answer", "clear", "first",
        "later", "right", "through"
    ]
}
