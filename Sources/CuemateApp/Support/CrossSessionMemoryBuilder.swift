import Foundation

/// Builds a compact cross-session memory note from past session records (CM-BLG-090).
///
/// Priority order for session matching:
/// 1. Same participant name (if non-empty)
/// 2. Same participant company (if non-empty and name is empty)
/// 3. Same meeting type (fallback)
struct CrossSessionMemoryBuilder: Sendable {

    struct MemoryNote: Sendable {
        let text: String
        let sessionCount: Int
        var isEmpty: Bool { text.isEmpty }
    }

    /// Builds a memory note relevant to the current session configuration.
    /// Returns an empty MemoryNote when there is no useful history.
    func build(
        for configuration: MeetingConfiguration,
        from pastSessions: [MeetingSessionRecord]
    ) -> MemoryNote {
        let relevant = selectRelevantSessions(for: configuration, from: pastSessions)
        guard !relevant.isEmpty else { return MemoryNote(text: "", sessionCount: 0) }

        var lines: [String] = []

        let count = relevant.count
        let mostRecent = relevant.first
        let scope = scopeLabel(for: configuration)
        lines.append("Prior history (\(scope)): \(count) session\(count == 1 ? "" : "s")")

        if let lastOutcome = relevant.compactMap(\.sessionOutcome).first {
            lines.append("Last outcome: \(lastOutcome.title)")
        }

        if let lastSummary = relevant.compactMap(\.summary).first {
            if !lastSummary.outcomeNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("Last result: \(lastSummary.outcomeNote.trimmingCharacters(in: .whitespacesAndNewlines))")
            }
            let openItems = lastSummary.actionItems
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(2)
            if !openItems.isEmpty {
                lines.append("Open commitments: " + openItems.joined(separator: "; "))
            }
        }

        let recurringTopics = topTopics(from: relevant, maxCount: 3)
        if !recurringTopics.isEmpty {
            lines.append("Recurring topics: " + recurringTopics.joined(separator: ", "))
        }

        let objectionPatterns = objectionSignals(from: relevant)
        if !objectionPatterns.isEmpty {
            lines.append("Past objections: " + objectionPatterns.joined(separator: ", "))
        }

        if let lastDate = mostRecent?.endedAt {
            let f = RelativeDateTimeFormatter()
            f.unitsStyle = .abbreviated
            lines.append("Last session: \(f.localizedString(for: lastDate, relativeTo: Date()))")
        }

        return MemoryNote(text: lines.joined(separator: "\n"), sessionCount: count)
    }

    // MARK: - Suggested answer style (CM-BLG-091)

    /// Returns the most-used `preferredAnswerStyle` across completed sessions for the given meeting type.
    /// Returns nil when there is not enough history to suggest a style.
    func suggestedAnswerStyle(
        meetingType: String,
        from pastSessions: [MeetingSessionRecord]
    ) -> String? {
        let styles = pastSessions
            .filter { !$0.isActive && $0.configuration.meetingType == meetingType }
            .compactMap { s -> String? in
                let style = s.configuration.preferredAnswerStyle
                return style.isEmpty ? nil : style
            }
        guard styles.count >= 2 else { return nil }
        let counts = Dictionary(grouping: styles, by: { $0 }).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - Helpers

    private func selectRelevantSessions(
        for config: MeetingConfiguration,
        from sessions: [MeetingSessionRecord]
    ) -> [MeetingSessionRecord] {
        let completed = sessions.filter { !$0.isActive }

        if !config.participantName.isEmpty {
            let byName = completed.filter {
                $0.configuration.participantName.lowercased() == config.participantName.lowercased()
            }
            if byName.count >= 1 { return Array(byName.prefix(6)) }
        }

        if !config.participantCompany.isEmpty {
            let byCompany = completed.filter {
                !$0.configuration.participantCompany.isEmpty &&
                $0.configuration.participantCompany.lowercased() == config.participantCompany.lowercased()
            }
            if byCompany.count >= 1 { return Array(byCompany.prefix(6)) }
        }

        return Array(completed
            .filter { $0.configuration.meetingType == config.meetingType }
            .prefix(4))
    }

    private func scopeLabel(for config: MeetingConfiguration) -> String {
        if !config.participantName.isEmpty { return config.participantName }
        if !config.participantCompany.isEmpty { return config.participantCompany }
        return config.meetingType.replacingOccurrences(of: "-", with: " ").capitalized
    }

    private func topTopics(from sessions: [MeetingSessionRecord], maxCount: Int) -> [String] {
        let counts = Dictionary(
            grouping: sessions.flatMap { $0.summary?.keyTopics ?? [] }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty },
            by: { $0 }
        ).mapValues(\.count)

        return counts
            .sorted { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }
            .prefix(maxCount)
            .map(\.key)
    }

    private func objectionSignals(from sessions: [MeetingSessionRecord]) -> [String] {
        let objectionWords = ["budget", "timing", "complexity", "trust", "adoption", "procurement", "legal", "security"]
        let allText = sessions.flatMap {
            [$0.summary?.outcomeNote ?? "", $0.summary?.overview ?? ""]
        }.joined(separator: " ").lowercased()

        return objectionWords.filter { allText.contains($0) }
    }
}
