import XCTest

import gimliTests

var tests = [XCTestCaseEntry]()
tests += gimliTests.allTests()
XCTMain(tests)