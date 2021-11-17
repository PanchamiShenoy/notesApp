//
//  passwordValidationTest.swift
//  SignUpLoginDemoTests
//
//  Created by Panchami Shenoy on 20/10/21.
//

import XCTest
@testable import SignUpLoginDemo

class passwordValidationTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testpasswordValidationEmptyStringsIsInvalid(){
        let result = utilities.isPasswordValid("")
        XCTAssertFalse(result)
      }
    func testpasswordValidationLessThanEightCharacterIsInvalid(){
        let result = utilities.isPasswordValid("aMbc12@")
        XCTAssertFalse(result)
      }
    func testpasswordValidationNoSpecialCharcterInvalid(){
        let result = utilities.isPasswordValid("qwerMty1234")
        XCTAssertFalse(result)
      }
    func testpasswordValidationNoNumberInvalid(){
        let result = utilities.isPasswordValid("qwertyM!@#$%")
        XCTAssertFalse(result)
      }
    func testpasswordValidationNoCapsInvalid(){
        let result = utilities.isPasswordValid("qwerty1!@#$%")
        XCTAssertFalse(result)
      }
    func testpasswordValidationForValid(){
        let result = utilities.isPasswordValid("qwerty1M!@#$%")
        XCTAssertTrue(result)
      }

    
}
