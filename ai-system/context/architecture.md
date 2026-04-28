# Architecture Context

## Repo Shape

This repository is a Swift Package Manager macOS app centered around a single executable target, `CuemateApp`.

Top-level areas:

- `Sources/CuemateApp/App`: app entry and high-level app model
- `Sources/CuemateApp/UI`: SwiftUI interface and workflow surfaces
- `Sources/CuemateApp/Audio`: microphone capture and voice activity handling
- `Sources/CuemateApp/Transcription`: Apple Speech and `whisper.cpp` transcription paths
- `Sources/CuemateApp/Conversation`: guidance generation and post-meeting summary logic
- `Sources/CuemateApp/Retrieval`: document ingestion, chunking, embeddings, and retrieval
- `Sources/CuemateApp/Storage`: local config and meeting-session persistence
- `Sources/CuemateApp/Support`: runtime helpers like hotkeys, dependency install, shell execution, and keychain access
- `Packaging/`: app bundle metadata and icons
- `scripts/`: helper scripts, including app packaging

## Runtime Model

The app is local-first. It captures audio, transcribes speech, builds context from live and stored data, and generates in-the-moment guidance for the user.

Supported guidance paths in source today include:

- local heuristic and local-model-oriented flows
- Ollama-backed generation
- optional OpenAI-backed generation

## Important Constraints

- Privacy and local-first behavior are part of the product identity and should remain visible in both code and docs.
- Source code is the canonical truth for supported features and runtime behavior.
- README and `product.html` should stay aligned with implementation and roadmap, while still being marketing-friendly.
- If a public site links to local build artifacts, confirm those artifacts are actually intended to ship in the repository.

