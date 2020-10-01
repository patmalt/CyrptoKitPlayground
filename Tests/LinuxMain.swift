import XCTest

import aes128Tests

var tests = [XCTestCaseEntry]()
tests += aes128Tests.allTests()
XCTMain(tests)
