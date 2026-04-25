import Foundation

/// Builds a structured follow-up email draft from a completed meeting session.
/// Uses transcript signals and meeting mode to produce a specific, non-generic draft.
struct FollowUpDraftBuilder: Sendable {
    private let modeHelper = MeetingModePromptHelper()

    struct DraftInput: Sendable {
        let meetingType: String
        let speakerName: String
        let actionItems: [String]
        let transcriptText: String
        let keyTopics: [String]
        let decisionSummary: String
    }

    struct FollowUpDraft: Sendable, Equatable {
        let subject: String
        let body: String

        var formatted: String {
            "Subject: \(subject)\n\n\(body)"
        }
    }

    func build(from input: DraftInput) -> FollowUpDraft {
        let signals = modeHelper.extractSignals(from: input.transcriptText)
        let subject = buildSubject(meetingType: input.meetingType, signals: signals, topics: input.keyTopics)
        let body = buildBody(input: input, signals: signals)
        return FollowUpDraft(subject: subject, body: body)
    }

    // MARK: - Subject line

    private func buildSubject(
        meetingType: String,
        signals: MeetingModePromptHelper.TranscriptSignals,
        topics: [String]
    ) -> String {
        switch meetingType {
        case "sales":
            if signals.hasPilotMention { return "Next step: pilot scope and timeline" }
            if signals.hasBudgetMention { return "Following up on pricing and next step" }
            if signals.hasTimelineMention { return "Quick follow-up and timeline recap" }
            return "Next step from our conversation"
        case "demo":
            if let topic = topics.first { return "Demo follow-up: \(topic)" }
            if signals.hasOnboardingSignal { return "Demo recap and onboarding path" }
            return "Demo recap and next workflow"
        case "client-review":
            if signals.hasConcernSignal { return "Review recap: open items and next actions" }
            if signals.hasDecisionSignal { return "Review recap: decisions and next step" }
            return "Review recap and next actions"
        case "interview":
            return "Thank you — and a quick follow-up"
        case "internal-sync":
            if signals.hasDecisionSignal { return "Sync recap: decisions and owners" }
            if signals.hasBlockerSignal { return "Sync recap: blockers and next step" }
            return "Sync recap and next actions"
        default:
            return "Meeting recap and next step"
        }
    }

    // MARK: - Body assembly

    private func buildBody(input: DraftInput, signals: MeetingModePromptHelper.TranscriptSignals) -> String {
        var parts: [String] = []

        parts.append(buildGreeting(meetingType: input.meetingType))
        parts.append(buildOpener(meetingType: input.meetingType, signals: signals))

        let decisionBlock = buildDecisionBlock(
            decisionSummary: input.decisionSummary,
            meetingType: input.meetingType,
            signals: signals
        )
        if !decisionBlock.isEmpty { parts.append(decisionBlock) }

        parts.append(buildActionBlock(items: input.actionItems, meetingType: input.meetingType))
        parts.append(buildClose(meetingType: input.meetingType, signals: signals))

        return parts.joined(separator: "\n\n")
    }

    private func buildGreeting(meetingType: String) -> String {
        switch meetingType {
        case "internal-sync": return "Team,"
        default: return "Hi,"
        }
    }

    private func buildOpener(
        meetingType: String,
        signals: MeetingModePromptHelper.TranscriptSignals
    ) -> String {
        switch meetingType {
        case "sales":
            if signals.hasPilotMention {
                return "Thanks for the conversation. Wanted to send a quick note on the pilot scope and how to structure the first step cleanly."
            }
            if signals.hasBudgetMention {
                return "Thanks for the time today. Wanted to follow up with the clearest next step and address the cost side directly."
            }
            if signals.hasTimelineMention {
                return "Thanks for the conversation. Wanted to capture the timeline we discussed and lock in the next step before anything drifts."
            }
            return "Thanks for the conversation today. Here is the short recap and the clearest next step we landed on."
        case "demo":
            if signals.hasOnboardingSignal {
                return "Thanks for the time. Here is a quick recap covering what we walked through and the most natural starting point for onboarding."
            }
            return "Thanks for the time. Here is a short recap of what we covered and the natural next workflow to continue with."
        case "client-review":
            if signals.hasConcernSignal {
                return "Thanks for the review. Wanted to capture the open items and the next accountable action while things are still fresh."
            }
            if signals.hasDecisionSignal {
                return "Thanks for the time today. Here is a short recap of the decisions made and the next step."
            }
            return "Thanks for the time today. Here is the short recap of progress and the next step."
        case "interview":
            return "Thank you for the conversation today — I appreciated the chance to dig into the role and what the team is working toward."
        case "internal-sync":
            if signals.hasDecisionSignal {
                return "Quick recap from the sync covering the decisions made and next owners."
            }
            return "Quick recap from the sync."
        default:
            return "Thanks for the conversation. Here is the short recap and next step."
        }
    }

    private func buildDecisionBlock(
        decisionSummary: String,
        meetingType: String,
        signals: MeetingModePromptHelper.TranscriptSignals
    ) -> String {
        guard !decisionSummary.isEmpty else { return "" }
        guard meetingType == "internal-sync" || signals.hasDecisionSignal else { return "" }
        return "Decision context:\n\(decisionSummary)"
    }

    private func buildActionBlock(items: [String], meetingType: String) -> String {
        let topItems = Array(items.prefix(3))
        let label: String
        switch meetingType {
        case "internal-sync": label = "Actions and owners:"
        case "interview":     label = "Next steps:"
        default:              label = "Next steps:"
        }

        if topItems.isEmpty {
            return "\(label)\n- Confirm the best follow-up from this meeting."
        }
        let lines = topItems.map { "- \($0)" }.joined(separator: "\n")
        return "\(label)\n\(lines)"
    }

    private func buildClose(
        meetingType: String,
        signals: MeetingModePromptHelper.TranscriptSignals
    ) -> String {
        if signals.hasSendRequest {
            return "I will follow up with the requested materials shortly."
        }
        switch meetingType {
        case "sales":
            if signals.hasTimelineMention {
                return "Let me know if the timeline shifts and I can reprioritise accordingly."
            }
            return "Let me know if the timing or scope changes and I can adjust."
        case "demo":
            return "Happy to tailor the next session around what resonated most today."
        case "client-review":
            return "Let me know if you want to add anything before I circulate this more broadly."
        case "interview":
            return "Looking forward to hearing about the next step in the process."
        case "internal-sync":
            return "Ping me if anything is unclear or if the owners change before the next checkpoint."
        default:
            return "Let me know if you want a shorter summary or a deeper follow-up."
        }
    }
}
