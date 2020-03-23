// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

extension XCTestCase {
    
    /// Return the URL to a unique temporary file, which is guaranteed not to exist.
    /// - Parameter named: The name to use for the file.
    /// - Parameter pathExtension: The extension to use for the file.
    public func temporaryFile(named: String? = nil, extension pathExtension: String? = nil) -> URL {
        let intervals = Date.timeIntervalSinceReferenceDate
        let root = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(intervals)")
        let bundle = Bundle(for: type(of: self))
        let folder = root.appendingPathComponent(bundle.bundleURL.lastPathComponent).deletingPathExtension()
        var file = folder.appendingPathComponent(self.name)
        file = file.appendingPathComponent(named ?? "test")
        if let ext = pathExtension {
            file = file.appendingPathExtension(ext)
        }
        
        try? FileManager.default.removeItem(at: file)
        return file
    }
    
    /// The bundle containing the currently running XCTestCase
    public var testBundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    /// Returns the URL to a resource included in the test bundle.
    /// By default this calls `url(forResource:withExtension)` on the bundle containing this code.
    ///
    /// If we're running a normal Xcode test target, and the resource file has been included in the target, then the
    /// current bundle should be the one containing this xctest, and that bundle should contain the resource file.
    ///
    /// If we're building with SPM, or with Xcode but from an SPM project (eg after opening Packages.swift in Xcode),
    /// then the xctest bundle with only contain the test code, and no data files. In this situation we use a bit of trickery
    /// to attempt to find the data files.
    /// If we're building from SPM, then the location of the test bundle should  be `.build`. In this case we can find
    /// the location of resource files if they're placed in a standard location, based on the following:
    /// - the build location has not been overridden with a custom value
    /// - the module's root folder matches the name of the module
    /// - the tests are in the standard path `Tests/<modulename>Tests/`
    /// - the resource files we want are in a subfolder of the tests folder, called `Resources`
    /// If we're building and SPM project from Xcode, then the location of the test bundle should be `Build` inside `DerivedData`.
    /// In this case we can find the location of the resources if they're placed in a standard location, based on:
    /// - the build location has not been overridden with a custom value
    /// - the module's root folder matches the name of the module
    /// - the tests are in the standard path `Tests/<modulename>Tests/`
    /// - the resource files we want are in a subfolder of the tests folder, called `Resources`
    ///
    /// If these assumptions are true for either of these cases, we can build a path to the resource file and return it that way.
    ///
    /// - Parameter name: Name of the resource file.
    /// - Parameter extension: Extension of the resource file.
    public func testURL(named name: String, withExtension extension: String) -> URL {
        let bundle = testBundle
        if let url = bundle.url(forResource: name, withExtension: `extension`) {
            return url
        }
        
        let container = bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        if container.lastPathComponent == ".build" {
            // we're building with SPM
            let root = container.deletingLastPathComponent()
            let module = root.deletingPathExtension().lastPathComponent
            return root.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(`extension`)")
        } else if container.lastPathComponent == "Build" {
            // we're building with Xcode, we can hopefully extract the workspace path from an Info.plist in the Build directory
            let root = container.deletingLastPathComponent()
            if let data = try? Data(contentsOf: root.appendingPathComponent("info.plist")) {
                if let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let info = plist as? NSDictionary {
                    if let path = info["WorkspacePath"] as? String {
                        let workspace = URL(fileURLWithPath: path)
                        if workspace.pathExtension == "" {
                            // if the extension is empty, we're building from the default auto-generated workspace
                            let module = workspace.deletingPathExtension().lastPathComponent
                            let url = workspace.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(`extension`)")
                            return url
                        } else {
                            // we're building from an explicit workspace - we assume it's at the root level of the project
                            // you can use this during development to set up a workspace which pulls in editable versions of dependencies
                            let root = workspace.deletingLastPathComponent()
                            let module = root.deletingPathExtension().lastPathComponent
                            let url = root.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(`extension`)")
                            return url
                        }
                    }
                }
            }
        }
        
        fatalError("can't find test resource \(name) of type \(`extension`)")
    }
    
    /// Returns some test data loaded form the test bundle.
    /// - Parameter name: Name of the resource file containing the data.
    /// - Parameter extension: Extension of the resource file containing the data.
    public func testData(named name: String, withExtension extension: String) -> Data {
        let url = testURL(named: name, withExtension: `extension`)
        return try! Data(contentsOf: url)
    }
    
    /// Returns a string loaded from the test bundle.
    /// - Parameter name: Name of the file containing the text.
    /// - Parameter extension: Extension of the file containing the text.
    public func testString(named name: String, withExtension extension: String) -> String {
        let data = testData(named: name, withExtension: `extension`)
        return String(data: data, encoding: .utf8)!
    }
    
    /// Looks up a flag in the environment variables.
    /// Returns true if it's not set, or set to a false-y value, true otherwise.
    /// Useful for conditionalising tests.
    /// - Parameter name: name of variable to check for.
    public func testFlag(_ name: String) -> Bool {
        guard let flag = ProcessInfo.processInfo.environment[name] else {
            return false
        }
        return (flag as NSString).boolValue
    }
    
    /// Returns path to the directory containing this test plugin.
    /// When running from Xcode, this should be the built products directory.
    public var productsDirectory: URL {
      #if !os(Linux)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
    
    #if os(macOS) || os(Linux)
    /// Run an external executable in the same location as the test bundle, and
    /// return its output.
    @available(macOS 10.13, *) public func run(_ command: String, arguments: [String] = []) -> XCTestRunner.Result {
        let runner = XCTestRunner(for: command)
        let result = runner.run(with: arguments)
        XCTAssertNotNil(result)
        return result!
    }
    #endif
}

/// Assert that a result is a success.
/// - Parameter result: The result to check.
/// - Parameter message: A message to print if the assertion fails.
/// - Parameter expectation: An expectation to fullfill if the assertion fails, or if it succeeds with no continuation provided.
/// - Parameter continuation: A continuation method to call if the assertion succeeded.
///
/// In an asynchronous setting, you're typically waiting for an expectation to be fullfilled before ending the test.
/// If this assertion failed, you may want to exit the tests early, which is why we accept an expectation to fullfill.
/// Conversely if the assertion succeeds, you may want to perform extra work, which is why we accept a continuation block.
/// If no continuation is provided, but an expectation was provided, we call the expectation if the assertion succeeds, on the
/// assumption that there's nothing more to do and we want to signal that the test is done.

public func XCTAssertSuccess<S,F>(_ result: Result<S,F>, message: String = "Failure", expectation: XCTestExpectation? = nil, continuation: ((S) -> Void)? = nil) {
    switch result {
    case .failure(let error):
        XCTFail("\(message): \(error)")
        expectation?.fulfill()
    case .success(let success):
        if let continuation = continuation {
            continuation(success)
        } else {
            expectation?.fulfill()
        }
    }
}

/// Assert that two strings are equal.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
/// It optionally ignores whitespace at the beginning/end of each line.
public func XCTAssertEqualLineByLine(_ string: String, _ expected: String, ignoringWhitespace: Bool = false, file: StaticString = #file, line fileLine: UInt = #line) {
    if string != expected {
        let lines = string.split(separator: "\n")
        let expectedLines = expected.split(separator: "\n")
        let lineCount = lines.count
        let expectedLineCount = expectedLines.count
        for n in 0 ..< min(lineCount, expectedLineCount) {
            var line = String(lines[n])
            var expectedLine = String(expectedLines[n])
            if ignoringWhitespace {
                line = line.trimmingCharacters(in: .whitespaces)
                expectedLine = expectedLine.trimmingCharacters(in: .whitespaces)
            }
            
            if line != expectedLine {
                XCTFail("Strings different at line \(n).\n\n\"\(line)\"\n\nvs.\n\n\"\(expectedLine)\"", file: file, line: fileLine)
                return
            }
        }
        
        if lineCount < expectedLineCount {
            let missing = expectedLines[lineCount ..< expectedLineCount].joined(separator: "\n")
            XCTFail("\(expectedLineCount - lineCount) lines missing from string.\n\n\(missing)", file: file, line: fileLine)
        } else if lineCount > expectedLineCount {
            let extra = lines[expectedLineCount ..< lineCount].joined(separator: "\n")
            XCTFail("\(lineCount - expectedLineCount) extra lines in string.\n\n\(extra)", file: file, line: fileLine)
        }
    }
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqual(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: false, file: file, line: line)
}

/// Assert that two strings are equal, ignoring whitespace at the beginning/end of each line.
/// If the strings don't match, this function compares them line by line to produce a more accurate description of the place where they differ.
public func XCTAssertEqualIgnoringWhitespace(_ string: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqualLineByLine(string, expected, ignoringWhitespace: true, file: file, line: line)
}

#if os(macOS) || os(Linux)
/// Assert that the result of running an external executable matches expected values.
@available(macOS 10.13, *) public func XCTAssertResult(_ result: XCTestRunner.Result, status: Int32, stdout: String, stderr: String, ignoringWhitespace: Bool = true, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(result.status, status, file: file, line: line)
    XCTAssertEqualLineByLine(result.stdout, stdout, ignoringWhitespace: ignoringWhitespace, file: file, line: line)
    XCTAssertEqualLineByLine(result.stderr, stderr, ignoringWhitespace: ignoringWhitespace, file: file, line: line)
}
#endif
