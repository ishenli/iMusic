//
//  searchTests.swift
//  iMusicTests
//
//  Created by michael.sl on 2022/6/15.
//
import Foundation
import XCTest
@testable import iMusic

class searchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testQQSearch() async throws {
      let vm = SearchViewModel()
      vm.platformSelected = 3
      await vm.fetch(keyword: "周杰伦")
//      XCTAssert(vm.searchList[0].album.name == "魔杰座")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
