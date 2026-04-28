import Foundation
import SwiftUI

// MARK: - State

/// Resolved state for the session history surface.
struct HistoryState: Sendable {
    let sessions: [MeetingSessionRecord]
    let documents: [IngestedDocument]
}

// MARK: - Coordinator

/// Loads and shapes data for the session history surface.
/// Keeps data access out of `SessionHistoryView` and keeps the view a pure render target.
struct SessionHistoryCoordinator: Sendable {
    let store: MeetingSessionStore
    let documentLibrary: DocumentLibrarySnapshot

    /// Loads all persisted sessions and pairs them with the current document library.
    /// Throws on I/O or decode failure — use `loadStateOrEmpty()` if you need a safe variant.
    func loadState() throws -> HistoryState {
        let sessions = try store.loadSessions()
        return HistoryState(sessions: sessions, documents: documentLibrary.documents)
    }

    /// Non-throwing variant — returns an empty `HistoryState` on any store failure.
    /// Suitable for use at app startup where a crash is not acceptable.
    func loadStateOrEmpty() -> HistoryState {
        HistoryState(
            sessions: store.loadSessionsSafely(),
            documents: documentLibrary.documents
        )
    }

    /// Produces a `SessionHistoryView` wired to the loaded state.
    @MainActor func makeView(from state: HistoryState) -> SessionHistoryView {
        SessionHistoryView(sessions: state.sessions, documents: state.documents)
    }
}
