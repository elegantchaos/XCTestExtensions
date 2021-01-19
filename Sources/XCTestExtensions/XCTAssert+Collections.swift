//
//  File.swift
//  
//
//  Created by Sam Developer on 19/01/2021.
//

import XCTest

public func XCTAssertEmpty<C>(_ collection: C, file: StaticString = #file, line: UInt = #line) where C: Collection {
    XCTAssertEqual(collection.count, 0, file: file, line: line)
}
