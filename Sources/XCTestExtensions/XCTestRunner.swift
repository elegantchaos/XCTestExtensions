// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

#if os(macOS) || os(Linux)
public class XCTestRunner {
    var environment: [String:String]
    let executable: URL
    public var cwd: URL?

    public enum Result {
        case ok(stdout: String, stderr: String)
        case failed(status: Int32, stdout: String, stderr: String)
        case launchError(error: Error)
    }

    /**
      Initialise with an explicit URL to the executable.
    */

    public init(for executable: URL, cwd: URL? = nil, environment: [String:String] = ProcessInfo.processInfo.environment) {
        self.executable = executable
        self.environment = environment
        self.cwd = cwd
    }


    /**
     Invoke a command and some optional arguments synchronously.
     Waits for the process to exit and returns the captured output plus the exit status.
     */

    public func run(with arguments: [String] = []) -> Result {
        let stdout = Pipe()
        let stderr = Pipe()
        let process = Process()
        if let cwd = cwd {
            process.currentDirectoryURL = cwd
        }
        process.executableURL = executable
        process.arguments = arguments
        process.standardOutput = stdout
        process.standardError = stderr
        process.environment = environment
        do {
            try process.run()
        } catch {
            return .launchError(error: error)
        }

        process.waitUntilExit()
        if process.terminationStatus == 0 {
            return .ok(stdout: stdout.asString, stderr: stderr.asString)
        } else {
            return .failed(status: process.terminationStatus, stdout: stdout.asString, stderr: stderr.asString)
        }
    }
    
    /// Extract text from an output pipe
    /// - Parameter source: the pipe
    func captureString(from pipe: Any?) -> String {
        if let pipe = pipe as? Pipe {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        return ""
    }
}

public extension Pipe {
    var asString: String {
        let data = fileHandleForReading.readDataToEndOfFile()
        return  String(data: data, encoding: .utf8) ?? ""
    }
}
#endif
