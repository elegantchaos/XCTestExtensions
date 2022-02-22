// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public extension XCTestCase {
    func asJSON<T>(_ value: T) -> String where T: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(data: try! encoder.encode(value), encoding: .utf8)!
    }
    
    func decode<T>(_ type: T.Type, fromJSON json: String) -> T where T: Decodable {
        let decoded = JSONDecoder()
        return try! decoded.decode(T.self, from: json.data(using: .utf8)!)
    }
}
