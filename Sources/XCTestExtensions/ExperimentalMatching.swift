// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/05/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public func matches<T>(_ a: T, _ b: T) -> Bool where T: Equatable, T: CustomStringConvertible {
    return a == b
}

public func matches<T>(_ a: T, _ b: T) -> Bool where T: Equatable {
    return a == b
}

public func matches<T>(_ a: T, _ b: T) -> Bool where T: CustomStringConvertible {
    return a.description == b.description
}

public func matches<T>(_ a: T, _ b: T) -> Bool where T: Matchable {
    return a.matches(b)
}
//
//extension Result: M2 {
//    public func matches<T>(_ a: T, _ b: T) -> Bool where T: CustomStringConvertible {
//        return a.description == b.description
//    }
//
//}
public protocol Matchable {
    func matches(_ other: Self) -> Bool
}

extension Matchable {
    func matches<T>(_ other: T) -> Bool where Self: Equatable, T: Equatable {
        guard type(of: self) == type(of: T.self) else { return false }
        return self == (other as! Self)
    }
}
//
//public protocol Matchable {
//    static func matches<A, B>(a: A, b: B) -> Bool
//}
//
//extension Matchable {
//    func matches<T>(a: T, b: T) -> Bool where T: Equatable {
//        return a == b
//    }
//
//    func matches<A, B>(a: A, b: B) -> Bool {
//        return type(of: A.self) != type(of: B.self)
//    }
//
//}
//
//public func matches<S,F>(a: Result<S,F>, b: Result<S,F>) -> Bool where S: Equatable, F: Equatable  {
//    if case let .success(d1) = a, case let .success(d2) = a {
//        return d1 == d2
//    } else if case let .failure(e1) = a, case let .failure(e2) = b {
//        return e1 == e2
//    } else {
//        return false
//    }
//}
//
//public func matches<S,F>(a: Result<S,F>, b: Result<S,F>) -> Bool where S: Equatable, F: CustomStringConvertible  {
//    if case let .success(d1) = a, case let .success(d2) = a {
//        return d1 == d2
//    } else if case let .failure(e1) = a, case let .failure(e2) = b {
//        return e1.description == e2.description
//    } else {
//        return false
//    }
//}
