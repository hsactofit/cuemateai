import Foundation

/// Read-only guidance for each meeting mode.
/// Single source of truth for mode-specific coaching, prompt text, and transcript-signal extraction.
/// Used by ConversationEngine, prompt builders, and PostMeetingSummaryService.
struct MeetingModePromptHelper: Sendable {

    // MARK: - Coaching objectives

    /// The primary coaching intent for live guidance in this mode.
    func coachingObjective(for meetingType: String) -> String {
        switch meetingType {
        case "sales":
            return "Drive toward a concrete pilot or qualified next step. Keep answers outcome-focused and concise."
        case "demo":
            return "Showcase workflow value clearly. Guide toward the most impactful feature to demonstrate next."
        case "client-review":
            return "Reinforce progress, name the main open risk, and close on one accountable next action."
        case "interview":
            return "Answer directly, tie experience to the outcome they care about, and stay concise."
        case "internal-sync":
            return "Push toward a decision, a clear owner, and the next unblocking action."
        default:
            return "Keep answers direct, practical, and easy to act on."
        }
    }

    /// Key signal words to watch for in transcript for this mode.
    func successSignals(for meetingType: String) -> [String] {
        switch meetingType {
        case "sales":
            return ["pilot", "next step", "budget", "timeline", "rollout", "contract", "decision", "procurement"]
        case "demo":
            return ["workflow", "show", "integrate", "use case", "team", "onboard", "feature", "adoption"]
        case "client-review":
            return ["progress", "risk", "milestone", "deadline", "blocker", "status", "delivery", "scope"]
        case "interview":
            return ["experience", "example", "challenge", "result", "outcome", "role", "team", "culture"]
        case "internal-sync":
            return ["decision", "owner", "blocker", "alignment", "priority", "deadline", "shipped", "blocked"]
        default:
            return ["next step", "follow up", "action", "decision", "plan"]
        }
    }

    /// Tone direction for written follow-ups in this mode.
    func followUpToneInstruction(for meetingType: String) -> String {
        switch meetingType {
        case "sales":
            return "Keep it tight. One next step. No fluff. Match their energy."
        case "demo":
            return "Reference what resonated. Point clearly to the next workflow."
        case "client-review":
            return "Professional and accountable. Name the open risk and the owner."
        case "interview":
            return "Warm but concise. Reinforce fit with one strong signal."
        case "internal-sync":
            return "Internal tone. Skip pleasantries. Name decisions and owners."
        default:
            return "Friendly, direct, one clear ask at the end."
        }
    }

    /// System prompt section for live AI guidance builders (Ollama, OpenAI).
    /// Describes the mode objective, key signals, and intent-specific tactics.
    func systemPromptSection(for meetingType: String, intent: String = "general") -> String {
        let obj = coachingObjective(for: meetingType)
        let sigs = successSignals(for: meetingType).joined(separator: ", ")
        let modeDetail = modeSpecificTactics(for: meetingType)
        let intentLine = intentSpecificGuidance(intent: intent, meetingType: meetingType)

        var lines = [
            "Mode (\(meetingType)): \(obj)",
            "Key signals: \(sigs)",
        ]
        if !modeDetail.isEmpty { lines.append(modeDetail) }
        if !intentLine.isEmpty { lines.append("Current moment (\(intent)): \(intentLine)") }
        return lines.joined(separator: "\n")
    }

    private func modeSpecificTactics(for meetingType: String) -> String {
        switch meetingType {
        case "sales":
            return """
            Sales tactics: Always close on one concrete next step (pilot, call, proposal, intro). \
            De-risk the ask — start small, prove value, expand later. \
            When budget comes up, reframe around ROI and start scope. \
            When timeline is the blocker, suggest one low-commitment action now. \
            Avoid long feature lists; anchor on one outcome they care about.
            """
        case "interview":
            return """
            Interview tactics: Structure answers as situation → action → outcome (keep each part tight). \
            Connect your experience to the outcome the interviewer cares about, not just what you did. \
            When asked about a weakness or gap, name it clearly then pivot to the mitigating action. \
            Avoid rambling — one strong 45-second answer beats a 3-minute one.
            """
        case "demo":
            return """
            Demo tactics: Lead with the workflow value before showing the feature. \
            If asked about a gap, acknowledge it and pivot to the strongest adjacent feature. \
            Watch for "can it do X" — answer yes/no first, then qualify. \
            Close each section with a question about their workflow to keep it conversational.
            """
        case "client-review":
            return """
            Client review tactics: Anchor on measurable progress first, then name the top open risk. \
            Don't hide risks — surfacing them builds trust. \
            Close each topic with a named owner and a date if possible. \
            If the client raises a concern, validate it before offering a solution.
            """
        case "internal-sync":
            return """
            Internal sync tactics: Push for a decision or a clear next-step owner at the end of each topic. \
            If something is blocked, name the dependency and the person who can unblock it. \
            Avoid restating the problem — move to resolution. \
            If alignment is unclear, ask a binary question to surface it.
            """
        default:
            return ""
        }
    }

    private func intentSpecificGuidance(intent: String, meetingType: String) -> String {
        switch intent {
        case "pricing":
            if meetingType == "sales" || meetingType == "demo" {
                return "Avoid defending the full price. Reframe around a focused starting scope and ROI. Offer a pilot or phased entry if budget is the blocker."
            }
            return "Give a direct answer on cost, then immediately anchor on value delivered."
        case "objection":
            if meetingType == "sales" {
                return "Acknowledge the concern clearly (one sentence). Propose a reversible low-risk next step. Do not oversell or argue. Make it easy to say yes to something small."
            }
            if meetingType == "interview" {
                return "If this is a concern about your experience, acknowledge the gap honestly, then give a concrete example of how you've compensated or learned fast."
            }
            return "Validate the concern, then offer one concrete path forward."
        case "decision":
            if meetingType == "sales" {
                return "Make it easy to say yes. Name exactly what the next step is, who does what, and by when. Remove ambiguity."
            }
            if meetingType == "internal-sync" {
                return "Force a binary: decide now, or name who decides by when. Avoid leaving the room without a clear owner."
            }
            return "Summarize the decision options clearly and recommend one."
        case "nextStep":
            if meetingType == "sales" {
                return "Close on one specific action: a call, a pilot proposal, an intro, or a document. Name the date. Don't leave it open-ended."
            }
            return "Name the next action, the owner, and the timeframe."
        case "proof":
            if meetingType == "sales" || meetingType == "demo" {
                return "Offer a concrete example, a customer story, or a metric. Keep it to one strong signal rather than a list."
            }
            if meetingType == "interview" {
                return "Give one specific example with a measurable outcome. Situation → action → result, tight."
            }
            return "Back the claim with one specific example or data point."
        case "clarification":
            return "Answer the clarification directly and concisely. If you need to verify something, say so — don't guess."
        default:
            return ""
        }
    }

    /// One-line participant context string for AI prompts.
    /// Returns an empty string when no context is set so call sites can skip it cleanly.
    func participantContextLine(for config: MeetingConfiguration) -> String {
        var parts: [String] = []
        if !config.participantName.isEmpty  { parts.append(config.participantName) }
        if !config.participantCompany.isEmpty { parts.append("(\(config.participantCompany))") }
        let stagePart: String
        switch config.relationshipStage {
        case "ongoing":   stagePart = "ongoing relationship"
        case "strategic": stagePart = "strategic account"
        default:          stagePart = "new contact"
        }
        parts.append(stagePart)
        let base = parts.joined(separator: " ")
        if !config.priorContextNote.isEmpty {
            return "\(base) — \(config.priorContextNote)"
        }
        return base
    }

    /// Prompt section for AI-backed pre-meeting brief generation.
    /// Describes the mode goal, focus areas, likely risks, and available context flags.
    /// Use this when building a prompt that should produce a structured pre-meeting brief.
    func preMeetingPromptSection(
        for meetingType: String,
        hasDocs: Bool,
        hasPriorSession: Bool
    ) -> String {
        let obj = coachingObjective(for: meetingType)
        let areas = summaryFocusAreas(for: meetingType).prefix(3).joined(separator: ", ")
        let risks = preMeetingRisksLine(for: meetingType)

        var lines: [String] = [
            "Pre-meeting mode (\(meetingType)):",
            "Session goal: \(obj)",
            "Focus areas: \(areas)",
            "Likely risks: \(risks)",
        ]
        if hasDocs {
            lines.append("Attached documents available — surface specific relevant context from them.")
        }
        if hasPriorSession {
            lines.append("Prior session of this type exists — reference continuity context where relevant.")
        }
        return lines.joined(separator: "\n")
    }

    /// One-line risks summary used by `preMeetingPromptSection`.
    private func preMeetingRisksLine(for meetingType: String) -> String {
        switch meetingType {
        case "sales":
            return "budget gating, missing decision-maker, timeline misalignment"
        case "demo":
            return "workflow mismatch, integration objection, unprepared use case"
        case "client-review":
            return "invisible progress, undiscussed risk, scope drift"
        case "interview":
            return "unprepared example, narrower requirements, experience gap"
        case "internal-sync":
            return "stalled decision, unclear ownership, external dependencies"
        default:
            return "goal drift, decision not reached"
        }
    }

    /// Focus areas for post-meeting summaries in this mode.
    func summaryFocusAreas(for meetingType: String) -> [String] {
        switch meetingType {
        case "sales":
            return ["qualified next step", "budget signal", "timeline", "objection raised", "pilot scope"]
        case "demo":
            return ["workflow shown", "resonance signal", "next feature to demo", "onboarding fit"]
        case "client-review":
            return ["progress confirmed", "risk raised", "open action item", "trust signal"]
        case "interview":
            return ["question topic", "example cited", "fit signal", "follow-up ask"]
        case "internal-sync":
            return ["decision made", "owner named", "blocker identified", "next checkpoint"]
        default:
            return ["key topic", "decision", "next step", "open question"]
        }
    }

    // MARK: - Transcript signal extraction

    struct TranscriptSignals: Sendable {
        let hasBudgetMention: Bool
        let hasTimelineMention: Bool
        let hasPilotMention: Bool
        let hasFollowUpMention: Bool
        let hasCommitmentSignal: Bool
        let hasConcernSignal: Bool
        let hasSendRequest: Bool
        let hasPriceMention: Bool
        let hasDecisionSignal: Bool
        let hasBlockerSignal: Bool
        let hasQuestionSignal: Bool
        let hasOnboardingSignal: Bool
    }

    func extractSignals(from transcript: String) -> TranscriptSignals {
        let t = transcript.lowercased()
        return TranscriptSignals(
            hasBudgetMention:     t.contains("budget") || t.contains("cost") || t.contains("spend"),
            hasTimelineMention:   t.contains("timeline") || t.contains("next week") || t.contains("this week")
                                   || t.contains("by end of") || t.contains("deadline") || t.contains("by friday"),
            hasPilotMention:      t.contains("pilot") || t.contains("trial") || t.contains("proof of concept")
                                   || t.contains("poc") || t.contains("test run"),
            hasFollowUpMention:   t.contains("follow up") || t.contains("follow-up")
                                   || t.contains("circle back") || t.contains("reach out"),
            hasCommitmentSignal:  t.contains("we will") || t.contains("we'll") || t.contains("i will")
                                   || t.contains("i'll") || t.contains("let's") || t.contains("agreed"),
            hasConcernSignal:     t.contains("concern") || t.contains("worry") || t.contains("issue")
                                   || t.contains("problem") || t.contains("blocker") || t.contains("risk"),
            hasSendRequest:       t.contains("send") || t.contains("share") || t.contains("forward")
                                   || t.contains("email me"),
            hasPriceMention:      t.contains("price") || t.contains("pricing") || t.contains("rate")
                                   || t.contains("quote"),
            hasDecisionSignal:    t.contains("decided") || t.contains("decision") || t.contains("agreed")
                                   || t.contains("confirmed") || t.contains("approved"),
            hasBlockerSignal:     t.contains("blocker") || t.contains("blocked") || t.contains("waiting on")
                                   || t.contains("dependency") || t.contains("stuck"),
            hasQuestionSignal:    t.contains("question") || t.contains("asking") || t.contains("curious about")
                                   || t.contains("wondering"),
            hasOnboardingSignal:  t.contains("onboard") || t.contains("set up") || t.contains("get started")
                                   || t.contains("kick off")
        )
    }
}
