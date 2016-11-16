//
//  testingResources.swift
//  pokitdokTests
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

import XCTest

public func throwsError(error: Error, block: () throws -> ()) -> Bool{
    /*
        Method to test that error is thrown when block is executed
        :PARAM error: error to test has occurred
        :PARAM block: code block to execute
        :RETURNS bool: true if expected error occurs
    */
    do {
        try block()
    }
    catch let e as Error {
        if type(of: e) == type(of: error) {
            return true
        }
        return false
    }
    return false
}

public func XCTAssertThrows(error: Error, block: () throws -> ()) {
    /*
        Method to assert that specific error is thrown
    */
    XCTAssert(throwsError(error: error, block: block))
}
