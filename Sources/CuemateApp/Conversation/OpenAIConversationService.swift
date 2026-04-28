import Foundation

struct OpenAIGenerationRequest: Sendable {
    let apiKey: String
    let request: ConversationRequest
}

enum OpenAIConversationError: LocalizedError {
    case invalidURL
    case badStatus(Int, String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "OpenAI URL is invalid"
        case .badStatus(let status, let body):
            return "OpenAI request failed with status \(status): \(body)"
        case .invalidResponse:
            return "OpenAI response could not be decoded"
        }
    }
}

struct OpenAIConversationService: Sendable {
    private let modeHelper = MeetingModePromptHelper()

    func generate(from input: OpenAIGenerationRequest) async throws -> ConversationResponse {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw OpenAIConversationError.invalidURL
        }

        let prompt = buildPrompt(from: input.request)
        let body = ChatCompletionsRequest(
            model: "gpt-4.1-mini",
            messages: [
                ChatMessage(role: "system", content: systemInstruction),
                ChatMessage(role: "user", content: prompt)
            ],
            temperature: 0.4
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(input.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenAIConversationError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw OpenAIConversationError.badStatus(http.statusCode, body)
        }

        let decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)
        guard
            let content = decoded.choices.first?.message.content,
            let payload = try? JSONDecoder().decode(ConversationResponsePayload.self, from: Data(content.utf8))
        else {
            throw OpenAIConversationError.invalidResponse
        }

        return ConversationResponse(
            primary: payload.primary,
            why: payload.why,
            next: payload.next,
            modeLabel: "OpenAI API"
        )
    }

    private func buildPrompt(from request: ConversationRequest) -> String {
        let you = request.userDisplayName
        let other = request.collaboratorRoleLabel
        let modeGuidance = modeHelper.systemPromptSection(for: request.configuration.meetingType, intent: request.detectedIntent)
        let participantContext = modeHelper.participantContextLine(for: request.configuration)
        let goalsSection = modeHelper.meetingGoalsSection(for: request.configuration)
        let memorySection = request.crossSessionMemory

        let latestQ = request.latestQuestion.map { seg in
            "\(other): \(seg.text.trimmingCharacters(in: .whitespacesAndNewlines))"
        } ?? "None"

        let priorTurns = request.transcriptSegments.filter { seg in
            seg.id != request.latestQuestion?.id
        }.prefix(3).map { seg in
            let label = seg.speaker.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                == you.lowercased() ? you : other
            return "\(label): \(seg.text.trimmingCharacters(in: .whitespacesAndNewlines))"
        }.joined(separator: "\n")

        let sources = request.retrievalResults.prefix(2).map { result in
            "[\(result.document.fileName)] \(result.chunk.text)"
        }.joined(separator: "\n")

        let participantLine = participantContext.isEmpty ? "\(other) (unknown contact)" : "\(other): \(participantContext)"

        var parts = [
            "Keep the primary answer to 1-2 short sentences. Prefer clarity over completeness.",
            "",
            "Participants: \(you) (user) | \(participantLine)",
            "Meeting type: \(request.configuration.meetingType) | tone: \(request.configuration.tone) | length: \(request.configuration.length) | level: \(request.configuration.userLevel)",
        ]
        if !goalsSection.isEmpty { parts.append(""); parts.append(goalsSection) }
        if !memorySection.isEmpty { parts.append(""); parts.append(memorySection) }
        parts += [
            "",
            "Latest statement/question to respond to:",
            latestQ,
            "",
            "Prior context (recent turns):",
            priorTurns.isEmpty ? "None" : priorTurns,
            "",
            "Retrieved knowledge:",
            sources.isEmpty ? "None" : sources,
            "",
            modeGuidance,
            "",
            "Return JSON with keys primary, why, next.",
        ]
        return parts.joined(separator: "\n")
    }

    private var systemInstruction: String {
        """
        You are a meeting copilot. Produce one concise thing the user should say now, one short why explanation, and one follow-up next step.
        Keep the primary answer short enough to scan instantly.
        Return strict JSON:
        {"primary":"...","why":"...","next":"..."}
        """
    }
}

private struct ChatCompletionsRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ChatCompletionsResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: ChatMessage
    }
}
