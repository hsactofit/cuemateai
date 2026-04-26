import Foundation

// MARK: - Strategy

/// Controls which AI provider (if any) enriches the heuristic brief.
enum BriefGenerationStrategy: Sendable {
    /// Return the pure heuristic brief — no network call.
    case heuristicOnly
    /// Enrich with a local Ollama instance; fall back to heuristic on failure.
    case ollama(model: String)
    /// Enrich with the OpenAI chat completions API; fall back to heuristic on failure.
    case openAI(apiKey: String, model: String)
}

// MARK: - Coordinator

/// Orchestrates pre-meeting brief generation.
///
/// Always produces a result — never throws. If the selected AI provider fails,
/// the coordinator falls back to the heuristic brief silently.
/// Decision logic lives here, not in views.
struct BriefCoordinator: Sendable {

    struct Input: Sendable {
        let configuration: MeetingConfiguration
        let snapshot: DocumentLibrarySnapshot
        let documentIDs: [UUID]
        let priorSessions: [MeetingSessionRecord]
        let strategy: BriefGenerationStrategy

        /// Convenience factory. Selects a strategy automatically:
        /// - Passes `ollamaModel` if provided and non-empty.
        /// - Passes `openAIKey`/`openAIModel` if both are non-empty.
        /// - Falls back to heuristic-only when neither is available.
        static func make(
            configuration: MeetingConfiguration,
            snapshot: DocumentLibrarySnapshot,
            documentIDs: [UUID],
            priorSessions: [MeetingSessionRecord],
            ollamaModel: String? = nil,
            openAIKey: String? = nil,
            openAIModel: String = "gpt-4o-mini"
        ) -> Input {
            let strategy: BriefGenerationStrategy
            if let model = ollamaModel, !model.isEmpty {
                strategy = .ollama(model: model)
            } else if let key = openAIKey, !key.isEmpty {
                strategy = .openAI(apiKey: key, model: openAIModel)
            } else {
                strategy = .heuristicOnly
            }
            return Input(
                configuration: configuration,
                snapshot: snapshot,
                documentIDs: documentIDs,
                priorSessions: priorSessions,
                strategy: strategy
            )
        }
    }

    func build(from input: Input) async -> MeetingBrief {
        let briefInput = MeetingBriefBuilder.BriefInput.from(
            configuration: input.configuration,
            snapshot: input.snapshot,
            documentIDs: input.documentIDs,
            priorSessions: input.priorSessions
        )
        let heuristic = MeetingBriefBuilder().build(from: briefInput)

        switch input.strategy {
        case .heuristicOnly:
            return heuristic

        case .ollama(let model):
            let request = OllamaBriefGenerationRequest(
                model: model,
                configuration: input.configuration,
                documentHighlights: heuristic.documentHighlights,
                priorSessionNote: heuristic.priorSessionNote
            )
            do {
                return try await OllamaBriefService().generateBrief(from: request)
            } catch {
                return heuristic
            }

        case .openAI(let apiKey, let model):
            let request = OpenAIBriefGenerationRequest(
                apiKey: apiKey,
                model: model,
                configuration: input.configuration,
                documentHighlights: heuristic.documentHighlights,
                priorSessionNote: heuristic.priorSessionNote
            )
            do {
                return try await OpenAIBriefService().generateBrief(from: request)
            } catch {
                return heuristic
            }
        }
    }
}
