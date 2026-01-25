import AppKit

enum SmokeTest {
    static let envKey = "SMOKE_TEST"
    static let outputEnvKey = "SMOKE_TEST_OUTPUT"
    static let argFlag = "--smoke-test"
    static let argOutputFlag = "--smoke-test-output"
    static let readyToken = "SMOKE_TEST_READY"
    private(set) static var didTrigger = false

    static func handleIfNeeded() {
        guard !didTrigger else { return }
        guard shouldRun else { return }
        didTrigger = true
        emitReady()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }

    static var shouldRun: Bool {
        if ProcessInfo.processInfo.environment[envKey] == "1" {
            return true
        }
        return ProcessInfo.processInfo.arguments.contains(argFlag)
    }

    static func emitReady() {
        guard let outputPath = smokeOutputPath(), !outputPath.isEmpty else {
            print(readyToken)
            return
        }
        let payload = readyToken + "\n"
        try? payload.write(toFile: outputPath, atomically: true, encoding: .utf8)
    }

    private static func smokeOutputPath() -> String? {
        if let envValue = ProcessInfo.processInfo.environment[outputEnvKey], !envValue.isEmpty {
            return envValue
        }
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: argOutputFlag) else { return nil }
        let valueIndex = args.index(after: flagIndex)
        guard valueIndex < args.endIndex else { return nil }
        return args[valueIndex]
    }
}
