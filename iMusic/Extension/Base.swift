//
//  Base.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/2.
//

import Foundation


class DurationTransformer: ValueTransformer {
  override func transformedValue(_ value: Any?) -> Any? {
    if let v = value as? Double {
      return (v / 1000).durationFormatter()
    }
    return "00:00"
  }
}


extension Double {
  func durationFormatter() -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: TimeInterval(self)) ?? "00:00"
  }
  
  
  // 224931 -> 03:44
  func duration2Date() -> String {
    let ss = floor(self / 1000)
    let min = floor(ss / 60)
    let last = ss - min * 60
    let first = Int(min) < 10 ? String("0") + String(Int(min)) : String(Int(min))
    let end = Int(last) < 10 ? String("0") + String(Int(last)) : String(Int(last))
    return first + " : " + end
  }
}

extension Int {
 
}

