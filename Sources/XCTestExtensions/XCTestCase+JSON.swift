// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public extension XCTestCase {
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 6.0, *) func asJSON<T>(_ value: T) -> String where T: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(data: try! encoder.encode(value), encoding: .utf8)!
    }
    
    func decode<T>(_ type: T.Type, fromJSON json: String) throws -> T where T: Decodable {
        let decoded = JSONDecoder()
        return try decoded.decode(T.self, from: json.data(using: .utf8)!)
    }
}
