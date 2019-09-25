// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 09/02/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

extension XCTestCase {

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

}
