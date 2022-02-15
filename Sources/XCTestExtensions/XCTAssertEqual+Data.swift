// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/02/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest

public func XCTAssertEqual(_ d1: Data, _ d2: Data, file: StaticString = #file, line: UInt = #line) {
    if d1 != d2 {
        let message = compareData(d1, d2)
        XCTFail(message, file: file, line: line)
    }
}


func compareData(_ actual: Data, _ expected: Data) -> String {
    // TODO: move this into Matchable?

    var mismatches: [Int] = []
    
    print(" Actual -- Expected")
    let count = min(actual.count, expected.count)
    for n in 0..<count {
        let a = actual[n]
        let e = expected[n]
        let div = a == e ? "--" : "**"
        if a != e {
            mismatches.append(n)
        }
        print("\(printable: a)  \(hexDigit: a)   \(div)   \(hexDigit: e)  \(printable: e)")
    }
    if actual.count > count {
        for n in count..<actual.count {
            print("\(printable: actual[n])  \(hexDigit: actual[n])")
        }
    } else if expected.count > count {
        for n in count..<expected.count {
            print("        --   \(hexDigit: expected[n])  \(printable: expected[n])")
        }
    }
    
    if mismatches.count > 0 {
        let n = mismatches.first!
        let a = actual[n]
        let e = expected[n]
        return "first mismatch at byte \(n): 0x\(hexDigit: a) (\(printable: a)) vs 0x\(hexDigit: e) (\(printable: e))"
    } else {
        return "got \(actual.count) bytes, expected \(expected.count) bytes"
    }
}

private extension String.StringInterpolation {
    static let printable: CharacterSet = CharacterSet.alphanumerics.union(.punctuationCharacters)

    mutating func appendInterpolation(printable byte: UInt8) {
        let output: String
        if let s = String(bytes: [byte], encoding: .ascii), let c = s.unicodeScalars.first, Self.printable.contains(c) {
            output = s
        } else {
            output = " "
        }

        appendInterpolation(output)
    }

    mutating func appendInterpolation<T>(hexDigit: T) where T: FixedWidthInteger {
        appendInterpolation(String(format: "%02X", Int(hexDigit)))
    }

    mutating func appendInterpolation(hex: Int) {
        appendInterpolation(String(format: "%0X", hex))
    }
}
