// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

extension XCTestCase {

    /// The name of the test case and the test.
    var testComponents: [String] {
        var name = self.name
        if name.starts(with: "-[") {
            name.removeFirst(2)
        }
        
        if name.last == "]" {
            name.removeLast()
        }
        
        return name.split(separator: " ").map({ String($0) })
    }

    
    /// The name of the test case and test, expressed as
    /// path components.
    var testComponentsPath: String {
        let components = testComponents
        
        return components.joined(separator: "/")
    }

    
    /// Return the URL to a folder that can be used to output test results to.
    /// By default we use the temporary directory, but the TestOutput environment
    /// variable can be set to a path to use instead.
    ///
    /// For example "~/Desktop/Test Results" will put the results into a
    /// folder on the desktop.
    public func outputDirectory(appendCaseName: Bool = true, appendTestName: Bool = true) -> URL {
        var url: URL
        if let path = ProcessInfo.processInfo.environment["TestOutput"] {
            let root = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
            url = root.appendingPathComponent(testBundleName)
        } else {
            url = temporaryDirectory()
        }

        let components = testComponents
        if appendCaseName && components.count > 0 {
            url.appendPathComponent(components[0])
        }
        
        if appendTestName && components.count > 1 {
            url.appendPathComponent(components[1])
        }
        
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    /// Return the URL to a file which can be used as to output test results to.
    /// The file is guaranteed not to exist (any previous file is deleted).
    /// - Parameter named: The name to use for the file.
    /// - Parameter pathExtension: The extension to use for the file.
    public func outputFile(named: String? = nil, extension pathExtension: String? = nil, subdirectory: String? = nil, root: URL? = nil) -> URL {
        var container = root ?? outputDirectory()
        if let path = subdirectory {
            container.appendPathComponent(path)
        }

        let fm = FileManager.default
        try? fm.createDirectory(at: container, withIntermediateDirectories: true)
        
        var file = container.appendingPathComponent(named ?? "test")
        if let ext = pathExtension {
            file = file.appendingPathExtension(ext)
        }
        
        try? fm.removeItem(at: file)
        return file
    }
    
    /// Return the URL to a folder that can be used to store temporary files
    public func temporaryDirectory() -> URL {
        let intervals = Date.timeIntervalSinceReferenceDate
        let root = URL(fileURLWithPath: NSTemporaryDirectory())
        let bundleRoot = root.appendingPathComponent(testBundleName)
        let folder = bundleRoot.appendingPathComponent("\(intervals)")
        return folder
    }
    
    /// Return the URL to a unique temporary file, which is guaranteed not to exist.
    /// - Parameter named: The name to use for the file.
    /// - Parameter pathExtension: The extension to use for the file.
    public func temporaryFile(named name: String? = nil, extension pathExtension: String? = nil) -> URL {
        return outputFile(named: name, extension: pathExtension, root: temporaryDirectory())
    }
    
    
    /// The bundle containing the currently running XCTestCase
    public var testBundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    /// Returns the name of this test bundle
    /// We use the executable name if available, as on Linux the bundle URL points to the build folder, and not an .xctest bundle.
    public var testBundleName: String {
        if let url = testBundle.executableURL {
            return url.deletingPathExtension().lastPathComponent
        } else {
            return testBundle.bundleURL.deletingPathExtension().lastPathComponent
        }
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
    public func testURL(named name: String, withExtension pathExtension: String) -> URL {
        let bundle = testBundle
        if let url = bundle.url(forResource: name, withExtension: pathExtension) {
            return url
        }
        
        // look for .build folder
        let names = [".build", "Build"]
        var container = bundle.bundleURL
        while container.isFileURL && !names.contains(container.lastPathComponent) {
            container.deleteLastPathComponent()
        }
        
        if container.lastPathComponent == ".build" {
            // we're building with SPM
            let root = container.deletingLastPathComponent()
            let module = root.deletingPathExtension().lastPathComponent
            return root.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(pathExtension)")
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
                            let url = workspace.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(pathExtension)")
                            return url
                        } else {
                            // we're building from an explicit workspace - we assume it's at the root level of the project
                            // you can use this during development to set up a workspace which pulls in editable versions of dependencies
                            let root = workspace.deletingLastPathComponent()
                            let module = root.deletingPathExtension().lastPathComponent
                            let url = root.appendingPathComponent("Tests").appendingPathComponent("\(module)Tests").appendingPathComponent("Resources").appendingPathComponent("\(name).\(pathExtension)")
                            return url
                        }
                    }
                }
            }
        }
        
        fatalError("can't find test resource \(name) of type \(pathExtension) (from \(bundle.bundleURL))")
    }
    
    /// Returns some test data loaded form the test bundle.
    /// - Parameter name: Name of the resource file containing the data.
    /// - Parameter extension: Extension of the resource file containing the data.
    public func testData(named name: String, withExtension pathExtension: String) -> Data {
        let url = testURL(named: name, withExtension: pathExtension)
        return try! Data(contentsOf: url)
    }
    
    /// Returns a string loaded from the test bundle.
    /// - Parameter name: Name of the file containing the text.
    /// - Parameter extension: Extension of the file containing the text.
    public func testString(named name: String, withExtension pathExtension: String) -> String {
        let data = testData(named: name, withExtension: pathExtension)
        return String(data: data, encoding: .utf8)!
    }
    
    /// Returns a json dictionary loaded from the test bundle.
    /// - Parameter name: Name of the file containing the dictionary.
    /// - Parameter extension: Extension of the file containing the text.
    public func testDictionary(named name: String, withExtension pathExtension: String = "json") throws -> [String:Any] {
        let url = testURL(named: name, withExtension: pathExtension)
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data) as! [String:Any]
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
    public func run(_ command: String, arguments: [String] = []) -> XCTestRunner.Result {
        let url = productsDirectory.appendingPathComponent(command)
        let runner = XCTestRunner(for: url)
        let result = runner.run(with: arguments)
        return result
    }
#endif
}
