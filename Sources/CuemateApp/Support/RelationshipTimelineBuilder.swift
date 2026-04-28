import Foundation

struct RelationshipSummary: Identifiable, Sendable {
    var id: String
    var displayName: String
    var company: String
    var sessionCount: Int
    var lastContact: Date
    var mostRecentOutcome: SessionOutcome?
    var allOutcomes: [SessionOutcome]
    var recurringTopics: [String]
    var sessions: [MeetingSessionRecord]
}

struct RelationshipTimelineBuilder: Sendable {
    func build(from sessions: [MeetingSessionRecord]) -> [RelationshipSummary] {
        let completed = sessions.filter { !$0.isActive }

        // Group by (participantName, participantCompany). Sessions with no participant name are skipped.
        var groups: [String: [MeetingSessionRecord]] = [:]
        for session in completed {
            let name = session.configuration.participantName.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }
            let key = groupKey(name: name, company: session.configuration.participantCompany)
            groups[key, default: []].append(session)
        }

        return groups.map { key, groupSessions in
            let sorted = groupSessions.sorted { ($0.endedAt ?? $0.startedAt) > ($1.endedAt ?? $1.startedAt) }
            let representative = sorted[0]
            let outcomes = sorted.compactMap(\.sessionOutcome)
            let topics = topTopics(from: sorted, limit: 4)

            return RelationshipSummary(
                id: key,
                displayName: representative.configuration.participantName,
                company: representative.configuration.participantCompany,
                sessionCount: sorted.count,
                lastContact: sorted[0].endedAt ?? sorted[0].startedAt,
                mostRecentOutcome: outcomes.first,
                allOutcomes: outcomes,
                recurringTopics: topics,
                sessions: sorted
            )
        }
        .sorted { $0.lastContact > $1.lastContact }
    }

    private func groupKey(name: String, company: String) -> String {
        let n = name.lowercased().trimmingCharacters(in: .whitespaces)
        let c = company.lowercased().trimmingCharacters(in: .whitespaces)
        return c.isEmpty ? n : "\(n)@\(c)"
    }

    private func topTopics(from sessions: [MeetingSessionRecord], limit: Int) -> [String] {
        var freq: [String: Int] = [:]
        for session in sessions {
            let topics = session.summary?.keyTopics ?? []
            for topic in topics {
                let normalized = topic.trimmingCharacters(in: .whitespaces).lowercased()
                guard !normalized.isEmpty else { continue }
                freq[normalized, default: 0] += 1
            }
        }
        return freq
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
}
