//
//  apiTests.swift
//  iMusicTests
//
//  Created by michael.sl on 2022/6/25.
//

import XCTest
@testable import iMusic

class apiTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testKWAPISongUrl() async throws {
    let api = KWMusic()
    let songUrl = await api.songUrl([440614]);
    XCTAssert(songUrl[0].url.host == "ip.h5.ra01.sycdn.kuwo.cn")
  }
  
  func testKWAPI_getToken() async throws {
    let api = KWMusic()
    let token = await api.getToken(isRetry: false)
    print(token)
  }
  
  
  func testKWAPI_search() async throws {
    let api = KWMusic()
    let res = await api.search(keywords: "周杰伦", page: 0, type: .songs)
    XCTAssert(res?.songs[0].artists[0].name == "周杰伦")
  }
  
  func testKWAPI_searchPlayList() async throws {
    let api = KWMusic()
    let res = await api.searchPlayList(keywords: "周杰伦", page: 0)
    XCTAssert(res?.playList[0].id == 2867496601)
  }
  
  func testQQAPI_fetchCategoryFilter() async throws {
    let api = QQMusic()
    let res = await api.fetchCategoryFilter()
    XCTAssert(res[0].categoryGroupName == "语种")
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
