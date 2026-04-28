import Foundation

struct AppState: Codable, Sendable {
    var configuration: MeetingConfiguration
    var overlayContent: OverlayContent
    var clickThroughEnabled: Bool
    var isPaused: Bool
    var overlayPinnedNearCamera: Bool
    var overlayAnchor: OverlayAnchor = .topCenter
    var overlayHorizontalInset: Double = 0
    var overlayVerticalInset: Double = 0
    var confidenceMode: String
    var currentSuggestionIndex: Int
    var transcriptionProvider: TranscriptionProvider = .appleSpeech
    var generationProvider: GenerationProvider = .localHeuristic
    var autoResponseEnabled: Bool = true
    var memoryEnabled: Bool = true
    var excludedFromMemoryIDs: [String] = []
    var offlineModeEnabled: Bool = false
    var screenContextEnabled: Bool = false
    var activePlaybookID: String = ""

    enum CodingKeys: String, CodingKey {
        case configuration, overlayContent, clickThroughEnabled, isPaused
        case overlayPinnedNearCamera, overlayAnchor, overlayHorizontalInset, overlayVerticalInset
        case confidenceMode, currentSuggestionIndex, transcriptionProvider, generationProvider
        case autoResponseEnabled, memoryEnabled, excludedFromMemoryIDs, offlineModeEnabled
        case screenContextEnabled, activePlaybookID
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try c.decode(MeetingConfiguration.self, forKey: .configuration)
        overlayContent = try c.decode(OverlayContent.self, forKey: .overlayContent)
        clickThroughEnabled = try c.decode(Bool.self, forKey: .clickThroughEnabled)
        isPaused = try c.decode(Bool.self, forKey: .isPaused)
        overlayPinnedNearCamera = try c.decode(Bool.self, forKey: .overlayPinnedNearCamera)
        overlayAnchor = (try? c.decode(OverlayAnchor.self, forKey: .overlayAnchor)) ?? .topCenter
        overlayHorizontalInset = (try? c.decode(Double.self, forKey: .overlayHorizontalInset)) ?? 0
        overlayVerticalInset = (try? c.decode(Double.self, forKey: .overlayVerticalInset)) ?? 0
        confidenceMode = try c.decode(String.self, forKey: .confidenceMode)
        currentSuggestionIndex = try c.decode(Int.self, forKey: .currentSuggestionIndex)
        transcriptionProvider = (try? c.decode(TranscriptionProvider.self, forKey: .transcriptionProvider)) ?? .appleSpeech
        generationProvider = (try? c.decode(GenerationProvider.self, forKey: .generationProvider)) ?? .localHeuristic
        autoResponseEnabled = (try? c.decode(Bool.self, forKey: .autoResponseEnabled)) ?? true
        memoryEnabled = (try? c.decode(Bool.self, forKey: .memoryEnabled)) ?? true
        excludedFromMemoryIDs = (try? c.decode([String].self, forKey: .excludedFromMemoryIDs)) ?? []
        offlineModeEnabled = (try? c.decode(Bool.self, forKey: .offlineModeEnabled)) ?? false
        screenContextEnabled = (try? c.decode(Bool.self, forKey: .screenContextEnabled)) ?? false
        activePlaybookID = (try? c.decode(String.self, forKey: .activePlaybookID)) ?? ""
    }

    init(configuration: MeetingConfiguration, overlayContent: OverlayContent,
         clickThroughEnabled: Bool, isPaused: Bool, overlayPinnedNearCamera: Bool,
         overlayAnchor: OverlayAnchor, overlayHorizontalInset: Double, overlayVerticalInset: Double,
         confidenceMode: String, currentSuggestionIndex: Int,
         transcriptionProvider: TranscriptionProvider, generationProvider: GenerationProvider,
         autoResponseEnabled: Bool, memoryEnabled: Bool, excludedFromMemoryIDs: [String],
         offlineModeEnabled: Bool, screenContextEnabled: Bool, activePlaybookID: String) {
        self.configuration = configuration
        self.overlayContent = overlayContent
        self.clickThroughEnabled = clickThroughEnabled
        self.isPaused = isPaused
        self.overlayPinnedNearCamera = overlayPinnedNearCamera
        self.overlayAnchor = overlayAnchor
        self.overlayHorizontalInset = overlayHorizontalInset
        self.overlayVerticalInset = overlayVerticalInset
        self.confidenceMode = confidenceMode
        self.currentSuggestionIndex = currentSuggestionIndex
        self.transcriptionProvider = transcriptionProvider
        self.generationProvider = generationProvider
        self.autoResponseEnabled = autoResponseEnabled
        self.memoryEnabled = memoryEnabled
        self.excludedFromMemoryIDs = excludedFromMemoryIDs
        self.offlineModeEnabled = offlineModeEnabled
        self.screenContextEnabled = screenContextEnabled
        self.activePlaybookID = activePlaybookID
    }
}

struct ConfigStore: Sendable {
    let appPaths: AppPaths
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(appPaths: AppPaths) {
        self.appPaths = appPaths
    }

    private var stateFileURL: URL {
        appPaths.configDirectory.appendingPathComponent("app-state.json")
    }

    func load() throws -> AppState {
        let data = try Data(contentsOf: stateFileURL)
        return try decoder.decode(AppState.self, from: data)
    }

    func save(_ state: AppState) throws {
        let configuredEncoder = JSONEncoder()
        configuredEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try configuredEncoder.encode(state)
        try data.write(to: stateFileURL, options: [.atomic])
    }
}
