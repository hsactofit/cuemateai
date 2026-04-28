import Foundation

struct TranscriptSegment: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let speaker: String
    let text: String
    let confidence: Double
    let isFinal: Bool
    let createdAt: Date
}

enum TranscriptSanitizer {
    private static let discardMarkers: Set<String> = [
        "[blank_audio]",
        "[blank_audo]",
        "blank_audio",
        "blank_audo",
        "[inaudible]"
    ]

    static func normalizedText(_ text: String) -> String? {
        let collapsed = text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !collapsed.isEmpty else { return nil }

        let lowered = collapsed.lowercased()
        guard !discardMarkers.contains(lowered) else { return nil }

        return collapsed
    }
}

enum TranscriptionState: String, Sendable {
    case idle
    case requestingPermission
    case ready
    case listening
    case denied
    case unavailable
    case failed
}
