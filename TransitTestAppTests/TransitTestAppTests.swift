//
//  TransitTestAppTests.swift
//  TransitTestAppTests
//
//  Created by Samantha Bennett on 9/16/21.
//

import XCTest
@testable import TransitTestApp

class TransitTestAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSONDeconding() throws {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "TransitTestFeed", withExtension: "json") else {
            XCTFail("Couldn't find json file")
            return
        }
        let json = try Data(contentsOf: url)
        let feeds = TransitFeeds.decodeJSON(data: json)
        XCTAssert(feeds.feeds.count > 0)
        let firstFeed = feeds.feeds.first
        XCTAssert(firstFeed != nil)
        XCTAssert(firstFeed!.name! == "STM")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
