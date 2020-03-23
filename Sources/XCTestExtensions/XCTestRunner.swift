// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 23/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

#if os(macOS) || os(Linux)
@available(macOS 10.13, *) public class XCTestRunner {
    var environment: [String:String]
    let executable: URL
    public var cwd: URL?

    public struct Result {
        public let status: Int32
        public let stdout: String
        public let stderr: String
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
      Initialise to run a command in the same built products directory as this test bundle.
    */

    public convenience init(for command: String, cwd: URL? = nil, environment: [String:String] = ProcessInfo.processInfo.environment) {
        let url = Bundle(for: XCTestRunner.self).bundleURL.deletingLastPathComponent()
        self.init(for: url.appendingPathComponent(command), cwd: cwd, environment: environment)
    }


    /**
     Invoke a command and some optional arguments synchronously.
     Waits for the process to exit and returns the captured output plus the exit status.
     */

    public func run(with arguments: [String] = []) -> Result? {
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
        process.launch()
        process.waitUntilExit()
        
        return Result(status: process.terminationStatus, stdout: stdout.asString, stderr: stderr.asString)
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
