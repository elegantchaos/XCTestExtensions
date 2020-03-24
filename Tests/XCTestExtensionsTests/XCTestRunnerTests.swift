// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/03/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import XCTestExtensions

#if os(macOS) || os(Linux)
final class XCTestRunnerTests: XCTestCase {
    func testRunner() {
        let runner = XCTestRunner(for: URL(fileURLWithPath: "/usr/bin/which"))
        let result = runner.run(with: ["ls"])
        XCTAssertResult(result, status: 0, stdout: "/bin/ls", stderr: "")
    }
}
#endif
