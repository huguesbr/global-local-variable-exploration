import XCTest
import Foundation

var testCases: [AnyClass] = []

class computedTests: XCTestCase {
    let formula = 2 * M_PI
    
    func testComputedGet() {
        var radius: Double = 1
        var circumference: Double {
            get {
                return radius * formula
            }
        }
        XCTAssertEqualWithAccuracy(circumference, 6.28, accuracy: 0.01)
    }
    
    func testComputedSet() {
        var radius: Double = 0
        var circumference: Double {
            get {
                return radius * formula
            }
            set {
                radius = newValue / formula
            }
        }
        circumference = 6.28
        XCTAssertEqualWithAccuracy(radius, 1, accuracy: 0.01)
    }
    
}
testCases.append(computedTests)

class observerTest: XCTestCase {
    
    func testWillSet() {
        weak var e = expectationWithDescription("should call willSet")
        var greeting: String = "Hello" {
            willSet(newValue) {
                XCTAssertEqual(greeting, "Hello")
                XCTAssertEqual(newValue, "Bye")
                e?.fulfill()
            }
        }
        greeting = "Bye"
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testDidSet() {
        weak var e = expectationWithDescription("should call didSet")
        var greeting: String = "Hello" {
            didSet(oldValue) {
                XCTAssertEqual(oldValue, "Hello")
                XCTAssertEqual(greeting, "Bye")
                e?.fulfill()
            }
        }
        greeting = "Bye"
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
}
testCases.append(observerTest)

//: Unit Test Boilerplate (tricky to move to source files)

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
    
    @objc func testCaseWillStart(testCase: XCTestCase) {
        print("Running: \(testCase.name)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.sharedTestObservationCenter()
center.addTestObserver(observer)

struct TestRunner {
    
    func runTests(testClass:AnyClass) {
        print("Running test suite \(testClass)")
        
        let tests = testClass as! XCTestCase.Type
        
        // grab the default test suit of the test case
        let testSuite = tests.defaultTestSuite()
        
        // run the test
        testSuite.runTest()
        
        // collect and display informations about the tests run
        let testRun = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(testRun.executionCount) tests in \(testRun.testDuration)s with \(testRun.totalFailureCount) failures")
    }
    
}

for testCase in testCases {
    TestRunner().runTests(testCase)
}
