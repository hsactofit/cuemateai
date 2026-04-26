import Foundation

// MARK: - Request

/// Input for AI-backed pre-meeting brief generation via OpenAI.
/// Mirror of `OllamaBriefGenerationRequest` — same shape, different transport.
struct OpenAIBriefGenerationRequest: Sendable {
    let apiKey: String
    let model: String
    let configuration: MeetingConfiguration
    /// Heuristic document highlights already extracted by MeetingBriefBuilder.
    let documentHighlights: [MeetingBrief.DocumentHighlight]
    /// Note from the most recent prior session of the same type, if any.
    let priorSessionNote: String?
}

// MARK: - Error

enum OpenAIBriefError: LocalizedError {
    case invalidURL
    case badStatus(Int, String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "OpenAI URL is invalid"
        case .badStatus(let code, let body):
            return "OpenAI brief request failed with status \(code): \(body)"
        case .invalidResponse:
            return "OpenAI brief response could not be decoded"
        }
    }
}

// MARK: - Service

/// Generates a `MeetingBrief` by posting to the OpenAI chat completions endpoint.
/// Uses `MeetingModePromptHelper.preMeetingPromptSection` as the shared prompt surface.
/// Decodes `BriefAIPayload` from the JSON response and assembles via `MeetingBriefBuilder`.
struct OpenAIBriefService: Sendable {
    private let modeHelper = MeetingModePromptHelper()

    func generateBrief(from input: OpenAIBriefGenerationRequest) async throws -> MeetingBrief {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw OpenAIBriefError.invalidURL
        }

        let body = OpenAIBriefAPIRequest(
            model: input.model,
            messages: buildMessages(from: input),
            responseFormat: OpenAIResponseFormat(type: "json_object"),
            temperature: 0.4,
            maxTokens: 600
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(input.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenAIBriefError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw OpenAIBriefError.badStatus(http.statusCode, body)
        }

        let raw = try JSONDecoder().decode(OpenAIBriefAPIResponse.self, from: data)
        guard
            let content = raw.choices.first?.message.content,
            let payloadData = content.data(using: .utf8),
            let payload = try? JSONDecoder().decode(BriefAIPayload.self, from: payloadData)
        else {
            throw OpenAIBriefError.invalidResponse
        }

        return MeetingBriefBuilder().assembleBrief(
            from: payload,
            meetingType: input.configuration.meetingType,
            documentHighlights: input.documentHighlights,
            priorSessionNote: input.priorSessionNote
        )
    }

    // MARK: - Messages

    private func buildMessages(from input: OpenAIBriefGenerationRequest) -> [OpenAIBriefMessage] {
        let modeSection = modeHelper.preMeetingPromptSection(
            for: input.configuration.meetingType,
            hasDocs: !input.documentHighlights.isEmpty,
            hasPriorSession: input.priorSessionNote != nil
        )

        var systemParts: [String] = [
            "You are a meeting preparation assistant. Produce a concise, practical pre-meeting brief.",
            "Keep each field short and actionable. Avoid filler.",
            "Respond only with a JSON object — no markdown, no prose.",
            "",
            modeSection,
        ]

        systemParts.append("")
        systemParts.append("Return a JSON object with exactly these keys:")
        systemParts.append("- meetingGoal: one sentence stating the primary session goal")
        systemParts.append("- focusAreas: array of 3–5 short strings naming areas to watch or drive")
        systemParts.append("- likelyRisks: array of 2–3 short strings naming objections or risks to anticipate")
        systemParts.append("- suggestedNextStep: one sentence on how to close the meeting toward a next step")
        systemParts.append("- openingFraming: one sentence on how to open the meeting with intent")
        systemParts.append("- priorSessionNote: a short sentence referencing prior session context, or empty string if none")

        var userParts: [String] = []

        if let note = input.priorSessionNote, !note.isEmpty {
            userParts.append("Prior session context: \(note)")
        }

        if !input.documentHighlights.isEmpty {
            userParts.append("Document highlights:")
            for highlight in input.documentHighlights {
                userParts.append("- [\(highlight.documentName)] \(highlight.relevantExcerpt)")
            }
        }

        if userParts.isEmpty {
            userParts.append("No documents or prior session context attached.")
        }

        return [
            OpenAIBriefMessage(role: "system", content: systemParts.joined(separator: "\n")),
            OpenAIBriefMessage(role: "user", content: userParts.joined(separator: "\n")),
        ]
    }
}

// MARK: - Private wire types

private struct OpenAIBriefAPIRequest: Codable {
    let model: String
    let messages: [OpenAIBriefMessage]
    let responseFormat: OpenAIResponseFormat
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case responseFormat = "response_format"
        case maxTokens = "max_tokens"
    }
}

private struct OpenAIBriefMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIResponseFormat: Codable {
    let type: String
}

private struct OpenAIBriefAPIResponse: Codable {
    let choices: [OpenAIBriefChoice]
}

private struct OpenAIBriefChoice: Codable {
    let message: OpenAIBriefMessage
}
