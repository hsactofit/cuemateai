import CoreAudio
import Foundation

struct AudioRoutingSnapshot: Sendable {
    let currentInput: String?
    let currentOutput: String?
    let inputDevices: [String]
    let outputDevices: [String]
    let blackHoleDevices: [String]
    let multiOutputDevices: [String]
    let headsetInputs: [String]
    let headsetOutputs: [String]

    var summary: String {
        let blackHoleReady = !blackHoleDevices.isEmpty
        let outputReady = currentOutput == "Multi-Output Device"

        if blackHoleReady && outputReady {
            return "Audio routing looks ready"
        }

        if blackHoleReady || outputReady {
            return "Audio routing is partially ready"
        }

        return "Audio routing still needs setup"
    }

    var detailLines: [String] {
        var lines: [String] = [
            "Current macOS input: \(currentInput ?? "Unknown")",
            "Current macOS output: \(currentOutput ?? "Unknown")"
        ]

        if blackHoleDevices.isEmpty {
            lines.append("BlackHole not detected yet. If you just installed it, restart the Mac once.")
        } else {
            lines.append("BlackHole detected: \(blackHoleDevices.joined(separator: ", "))")
        }

        if multiOutputDevices.isEmpty {
            lines.append("Multi-Output Device not found in CoreAudio.")
        } else if currentOutput == "Multi-Output Device" {
            lines.append("System sound is routed through Multi-Output Device.")
        } else {
            lines.append("Multi-Output Device exists, but it is not the current macOS output.")
        }

        lines.append(
            headsetOutputs.isEmpty
                ? "No external earphone/headphone output detected."
                : "Earphone/headphone outputs: \(headsetOutputs.joined(separator: ", "))"
        )
        lines.append(
            headsetInputs.isEmpty
                ? "No external earphone/headset microphone detected."
                : "Earphone/headset microphones: \(headsetInputs.joined(separator: ", "))"
        )

        if !inputDevices.isEmpty {
            lines.append("All input devices: \(inputDevices.joined(separator: ", "))")
        }
        if !outputDevices.isEmpty {
            lines.append("All output devices: \(outputDevices.joined(separator: ", "))")
        }

        return lines
    }
}

struct AudioRoutingDiagnosticsService: Sendable {
    func inspect() -> AudioRoutingSnapshot {
        let devices = listDevices()
        let currentInputID = defaultDeviceID(selector: kAudioHardwarePropertyDefaultInputDevice)
        let currentOutputID = defaultDeviceID(selector: kAudioHardwarePropertyDefaultOutputDevice)

        let currentInput = devices.first(where: { $0.id == currentInputID })?.name
        let currentOutput = devices.first(where: { $0.id == currentOutputID })?.name
        let inputDevices = devices.filter(\.hasInput).map(\.name).sorted()
        let outputDevices = devices.filter(\.hasOutput).map(\.name).sorted()
        let blackHoleDevices = devices
            .filter { $0.name.localizedCaseInsensitiveContains("BlackHole") }
            .map(\.name)
            .sorted()
        let multiOutputDevices = devices
            .filter { $0.name == "Multi-Output Device" }
            .map(\.name)
        let headsetInputs = devices
            .filter { $0.hasInput && isLikelyHeadset(name: $0.name) }
            .map(\.name)
            .sorted()
        let headsetOutputs = devices
            .filter { $0.hasOutput && isLikelyHeadset(name: $0.name) }
            .map(\.name)
            .sorted()

        return AudioRoutingSnapshot(
            currentInput: currentInput,
            currentOutput: currentOutput,
            inputDevices: inputDevices,
            outputDevices: outputDevices,
            blackHoleDevices: blackHoleDevices,
            multiOutputDevices: multiOutputDevices,
            headsetInputs: headsetInputs,
            headsetOutputs: headsetOutputs
        )
    }

    private func listDevices() -> [AudioDeviceDescriptor] {
        let systemObject = AudioObjectID(kAudioObjectSystemObject)
        var address = propertyAddress(kAudioHardwarePropertyDevices)
        var dataSize: UInt32 = 0

        guard AudioObjectGetPropertyDataSize(systemObject, &address, 0, nil, &dataSize) == noErr else {
            return []
        }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.stride
        var deviceIDs = Array(repeating: AudioDeviceID(0), count: count)

        guard AudioObjectGetPropertyData(systemObject, &address, 0, nil, &dataSize, &deviceIDs) == noErr else {
            return []
        }

        return deviceIDs.map { id in
            AudioDeviceDescriptor(
                id: id,
                name: stringProperty(for: id, selector: kAudioObjectPropertyName) ?? "Unknown",
                hasInput: streamCount(for: id, scope: kAudioDevicePropertyScopeInput) > 0,
                hasOutput: streamCount(for: id, scope: kAudioDevicePropertyScopeOutput) > 0
            )
        }
    }

    private func defaultDeviceID(selector: AudioObjectPropertySelector) -> AudioDeviceID? {
        let systemObject = AudioObjectID(kAudioObjectSystemObject)
        var address = propertyAddress(selector)
        var deviceID = AudioDeviceID(0)
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.stride)

        guard AudioObjectGetPropertyData(systemObject, &address, 0, nil, &dataSize, &deviceID) == noErr else {
            return nil
        }

        return deviceID
    }

    private func stringProperty(for deviceID: AudioDeviceID, selector: AudioObjectPropertySelector) -> String? {
        var address = propertyAddress(selector)
        var unmanagedValue: Unmanaged<CFString>?
        var dataSize = UInt32(MemoryLayout<Unmanaged<CFString>?>.stride)

        guard AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &unmanagedValue) == noErr else {
            return nil
        }

        return unmanagedValue?.takeUnretainedValue() as String?
    }

    private func streamCount(for deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
        var address = propertyAddress(kAudioDevicePropertyStreams, scope: scope)
        var dataSize: UInt32 = 0

        guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize) == noErr else {
            return 0
        }

        return Int(dataSize) / MemoryLayout<AudioStreamID>.stride
    }

    private func propertyAddress(
        _ selector: AudioObjectPropertySelector,
        scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
        element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain
    ) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
    }

    private func isLikelyHeadset(name: String) -> Bool {
        let lowered = name.lowercased()
        let keywords = ["airpods", "earpods", "headphone", "headset", "buds", "beats", "jabra", "bose", "sony"]
        return keywords.contains(where: lowered.contains)
    }
}

private struct AudioDeviceDescriptor: Sendable {
    let id: AudioDeviceID
    let name: String
    let hasInput: Bool
    let hasOutput: Bool
}
