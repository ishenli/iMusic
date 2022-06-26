//
//  GoTests.swift
//  GoTests
//
//  Created by michael.sl on 2022/6/12.
//

import XCTest
@testable import iMusic

// 参考代码：https://github.com/Alamofire/Alamofire/blob/master/Tests/CacheTests.swift
// 参考文档：https://blog.csdn.net/lin1109221208/article/details/91955462

class GoTests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testTime() throws {
    let a = "go"
    XCTAssert(a=="go")
    
    let createTime = 1547967528504 / 1000
    let df = DateFormatter()
    df.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
    //      let date = df.date(from: String(1490837055281))
    let interval:TimeInterval = TimeInterval.init(Double(createTime))
    let date = Date(timeIntervalSince1970: interval)
    let createTimeStr = df.string(from: date)
    print(createTimeStr)
    
  }
  
  func testCurrentTime() {
    
    let now = Date()
    
    let timeInterval: TimeInterval = now.timeIntervalSince1970
    
    let timeStamp = Int(timeInterval)
    
    print("当前时间的时间戳：\(timeStamp)")
    
    
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
    
    print("当前日期时间：\(dateformatter.string(from: now))")
  }
  
  func testString2Date() {
    let timeStamp = 1463241600
    
    //转换为时间
    let timeInterval:TimeInterval = TimeInterval(timeStamp)
    
    let date = Date(timeIntervalSince1970: timeInterval)
    
    let dateformatter = DateFormatter()
    
    dateformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss" //自定义日期格式
    
    let time = dateformatter.string(from: date)
    
    print("对应时间:"+time)
  }
  
  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
