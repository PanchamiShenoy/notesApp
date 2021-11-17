//
//  EmailValidationTest.swift
//  SignUpLoginDemoTests
//
//  Created by Panchami Shenoy on 20/10/21.
//

import XCTest
@testable import SignUpLoginDemo
class EmailValidationTest: XCTestCase {

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
    func testEmailValidationEmptyStringsIsInvalid(){
        let result = utilities.isEmailValid("")
        XCTAssertFalse(result)
      }
    
    func testEmailValidationWithoutComIsInvalid(){
        let result = utilities.isEmailValid("panchami@gmail.")
        XCTAssertFalse(result)
      }
    func testEmailValidationWithoutAtTheRateIsInvalid(){
        let result = utilities.isEmailValid("panchamigmail.com")
        XCTAssertFalse(result)
      }
    func testEmailValidationWithoutDotsInvalid(){
        let result = utilities.isEmailValid("panchamigmailcom")
        XCTAssertFalse(result)
      }
    func testEmailValidationIsValid(){
        let result = utilities.isEmailValid("panchami@gmail.com")
        XCTAssertTrue(result)
      }
    

}
