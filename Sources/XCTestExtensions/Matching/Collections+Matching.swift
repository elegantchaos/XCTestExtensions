// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 29/04/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

extension Array: Matchable where Element: Matchable {
    public func matches(_ other: Array<Element>, context: MatchableContext) throws {
        for (a,b) in zip(self, other) {
            try a.matches(b, context: context)
        }
    }
}

extension Set: Matchable where Element: Matchable {
    public func matches(_ other: Set<Element>, context: MatchableContext) throws {
        if self != other {
            throw MatchFailedError("Set contents differ", value: self, expected: other, context: context)
            // TODO: report more about the exact difference - eg first non-matching element
        }
    }
}

extension Dictionary: Matchable where Value: Equatable {
    public func matches(_ other: Dictionary, context: MatchableContext) throws {
        if self != other {
            throw MatchFailedError("Dictionary contents differ", value: self, expected: other, context: context)
            // TODO: report more about the exact difference - eg first non-matching key
        }
    }
}
