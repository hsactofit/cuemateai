import CoreGraphics
import Foundation
import Vision

/// Captures the primary display and extracts visible text via on-device OCR.
/// Text is held in memory only — never written to disk or sent anywhere the user has not authorised.
@MainActor
final class ScreenContextService {

    /// The most recently extracted on-screen text. Empty until `captureAndExtractText()` succeeds.
    private(set) var lastCapturedText: String = ""
    private(set) var lastCaptureAt: Date?

    // MARK: - Permission

    /// Returns true if the app already has Screen Recording permission.
    func hasPermission() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Triggers the macOS Screen Recording permission dialog if not yet granted.
    /// The user must grant access in System Settings; there is no programmatic approval.
    func requestPermission() {
        CGRequestScreenCaptureAccess()
    }

    // MARK: - Capture

    /// Captures the primary display, runs on-device OCR, stores and returns the result.
    /// Returns an empty string on permission denial, capture failure, or when no text is found.
    func captureAndExtractText() async -> String {
        guard hasPermission() else { return "" }

        let displayID = CGMainDisplayID()
        guard let cgImage = CGDisplayCreateImage(displayID) else { return "" }

        let text = await recognizeText(in: cgImage)
        lastCapturedText = text
        lastCaptureAt = Date()
        return text
    }

    // MARK: - OCR (private)

    private func recognizeText(in image: CGImage) async -> String {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                continuation.resume(returning: text)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: "")
            }
        }
    }
}
