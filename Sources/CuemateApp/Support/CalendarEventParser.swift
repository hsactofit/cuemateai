import Foundation

// MARK: - Model

/// Structured meeting context extracted from an ICS calendar event file.
struct CalendarEventRecord: Sendable {
    let title: String
    let startDate: Date?
    let endDate: Date?
    let attendeeNames: [String]
    let agenda: String
    let location: String

    /// Formatted one-block summary suitable for prompt injection.
    var calendarContextSummary: String {
        var lines: [String] = []

        if !title.isEmpty { lines.append("Meeting: \(title)") }

        if let start = startDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            var timeLine = "When: \(formatter.string(from: start))"
            if let end = endDate {
                let endFormatter = DateFormatter()
                endFormatter.timeStyle = .short
                timeLine += " – \(endFormatter.string(from: end))"
            }
            lines.append(timeLine)
        }

        if !location.isEmpty { lines.append("Location: \(location)") }

        if !attendeeNames.isEmpty {
            lines.append("Attendees: \(attendeeNames.joined(separator: ", "))")
        }

        if !agenda.isEmpty {
            lines.append("Agenda/notes: \(agenda)")
        }

        return lines.joined(separator: "\n")
    }

    var isEmpty: Bool {
        title.isEmpty && attendeeNames.isEmpty && agenda.isEmpty
    }
}

// MARK: - Parser

/// Parses a subset of the iCalendar (RFC 5545) format.
/// Extracts SUMMARY, DTSTART, DTEND, ATTENDEE CN= names, DESCRIPTION, and LOCATION.
/// Silently ignores unknown lines — returns a best-effort result on partial files.
struct CalendarEventParser: Sendable {

    enum ParseError: LocalizedError {
        case notICSFile
        case noEventFound

        var errorDescription: String? {
            switch self {
            case .notICSFile: "The file does not appear to be a valid .ics calendar file."
            case .noEventFound: "No VEVENT block was found in the calendar file."
            }
        }
    }

    func parse(icsText: String) throws -> CalendarEventRecord {
        let lines = unfold(icsText)

        guard lines.contains(where: { $0.trimmingCharacters(in: .whitespaces) == "BEGIN:VCALENDAR" }) else {
            throw ParseError.notICSFile
        }
        guard lines.contains(where: { $0.trimmingCharacters(in: .whitespaces) == "BEGIN:VEVENT" }) else {
            throw ParseError.noEventFound
        }

        var inEvent = false
        var title = ""
        var startDate: Date? = nil
        var endDate: Date? = nil
        var attendees: [String] = []
        var description = ""
        var location = ""

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed == "BEGIN:VEVENT" { inEvent = true; continue }
            if trimmed == "END:VEVENT" { break }
            guard inEvent else { continue }

            // Split on first colon only; value may contain colons (e.g. dates, URLs).
            let (key, value) = splitICSLine(trimmed)

            if key == "SUMMARY" {
                title = unescapeICS(value)
            } else if key.hasPrefix("DTSTART") {
                startDate = parseICSDate(value)
            } else if key.hasPrefix("DTEND") {
                endDate = parseICSDate(value)
            } else if key.hasPrefix("ATTENDEE") {
                if let cn = extractCN(from: key, value: value) {
                    attendees.append(cn)
                }
            } else if key == "DESCRIPTION" {
                description = unescapeICS(value)
            } else if key == "LOCATION" {
                location = unescapeICS(value)
            }
        }

        return CalendarEventRecord(
            title: title,
            startDate: startDate,
            endDate: endDate,
            attendeeNames: attendees,
            agenda: description,
            location: location
        )
    }

    func parse(contentsOf url: URL) throws -> CalendarEventRecord {
        let text = try String(contentsOf: url, encoding: .utf8)
        return try parse(icsText: text)
    }

    // MARK: - Private helpers

    /// RFC 5545 line unfolding: a CRLF or LF followed by a single whitespace is a continuation.
    private func unfold(_ text: String) -> [String] {
        let normalised = text.replacingOccurrences(of: "\r\n", with: "\n")
        let unfolded = normalised.replacingOccurrences(of: "\n ", with: "")
                                 .replacingOccurrences(of: "\n\t", with: "")
        return unfolded.components(separatedBy: "\n")
    }

    /// Splits "KEY;param=val:VALUE" into ("KEY;param=val", "VALUE").
    private func splitICSLine(_ line: String) -> (String, String) {
        guard let colonIdx = line.firstIndex(of: ":") else { return (line, "") }
        let key = String(line[..<colonIdx])
        let value = String(line[line.index(after: colonIdx)...])
        return (key, value)
    }

    /// Extracts CN= common name from ATTENDEE property key or value.
    /// Handles: ATTENDEE;CN="Alice Smith":mailto:... and ATTENDEE;CN=Alice:mailto:...
    private func extractCN(from key: String, value: String) -> String? {
        let combined = key + ":" + value
        guard let cnRange = combined.range(of: "CN=", options: .caseInsensitive) else { return nil }
        let afterCN = String(combined[cnRange.upperBound...])

        // Strip surrounding quotes if present.
        if afterCN.hasPrefix("\"") {
            let inner = String(afterCN.dropFirst())
            return inner.components(separatedBy: "\"").first?.trimmingCharacters(in: .whitespaces)
        }

        // Stop at next semicolon or colon.
        let name = afterCN.components(separatedBy: CharacterSet(charactersIn: ";:")).first ?? afterCN
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Parses RFC 5545 date-time strings: 20240515T140000Z or 20240515T140000 or 20240515.
    private func parseICSDate(_ value: String) -> Date? {
        let clean = value.trimmingCharacters(in: .whitespaces)

        let formatters: [(String, Bool)] = [
            ("yyyyMMdd'T'HHmmss'Z'", true),
            ("yyyyMMdd'T'HHmmss", false),
            ("yyyyMMdd", false),
        ]

        for (format, isUTC) in formatters {
            let f = DateFormatter()
            f.dateFormat = format
            f.locale = Locale(identifier: "en_US_POSIX")
            if isUTC { f.timeZone = TimeZone(identifier: "UTC") }
            if let date = f.date(from: clean) { return date }
        }
        return nil
    }

    /// Undoes ICS text escaping: \n → newline, \, → comma, \; → semicolon, \\ → backslash.
    private func unescapeICS(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\N", with: "\n")
            .replacingOccurrences(of: "\\,", with: ",")
            .replacingOccurrences(of: "\\;", with: ";")
            .replacingOccurrences(of: "\\\\", with: "\\")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
