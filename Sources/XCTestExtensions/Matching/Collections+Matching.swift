// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Array: Matchable where Element: Matchable {
    public func matches(_ other: Array<Element>, context: MatchableContext) throws {
        if count != other.count {
            throw MatchFailedError("Counts differ for \(Self.self)", value: count, expected: other.count, context: context)
        }

        try count.matches(other.count, context: context)
        for (a,b) in zip(self, other) {
            try a.matches(b, context: context)
        }
    }
}

extension Set: Matchable where Element: Matchable {
    public func matches(_ other: Set<Element>, context: MatchableContext) throws {
        if self != other {
            throw MatchFailedError("Contents differ for \(Self.self).", value: self, expected: other, context: context)
            // TODO: report more about the exact difference - eg first non-matching element
        }
    }
}

extension Dictionary: Matchable where Value: Equatable {
    public func matches(_ other: Dictionary, context: MatchableContext) throws {
        if self != other {
            throw MatchFailedError("Contents differ for \(Self.self).", value: self, expected: other, context: context)
            // TODO: report more about the exact difference - eg first non-matching key
        }
    }
}
