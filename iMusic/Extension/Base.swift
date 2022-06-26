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
    if (self.isNaN) {
      return "00:00"
    }
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



extension Encodable {
    func jsonString() -> String {
        guard let data = try? JSONEncoder().encode(self),
            let str = String(data: data, encoding: .utf8) else {
                return ""
        }
        return str
    }
}


extension Date {
   /// 获取当前 秒级 时间戳 - 10位
   var timeStamp : String {
       let timeInterval: TimeInterval = self.timeIntervalSince1970
       let timeStamp = Int(timeInterval)
       return "\(timeStamp)"
   }

   /// 获取当前 毫秒级 时间戳 - 13位
   var milliStamp : String {
       let timeInterval: TimeInterval = self.timeIntervalSince1970
       let millisecond = CLongLong(round(timeInterval*1000))
       return "\(millisecond)"
   }
}


extension String {
  func subString(from startString: String, to endString: String) -> String {
    var str = self
    if let startIndex = self.range(of: startString)?.upperBound {
      str.removeSubrange(str.startIndex ..< startIndex)
      if let endIndex = str.range(of: endString)?.lowerBound {
        str.removeSubrange(endIndex ..< str.endIndex)
        return str
      }
    }
    return ""
  }
  
  func subString(from startString: String) -> String {
    var str = self
    if let startIndex = self.range(of: startString)?.upperBound {
      str.removeSubrange(self.startIndex ..< startIndex)
      return str
    }
    return ""
  }
  
  func subString(to endString: String) -> String {
    var str = self
    if let endIndex = self.range(of: endString)?.lowerBound {
      str.removeSubrange(endIndex ..< str.endIndex)
      return str
    }
    return ""
  }
}


extension String {
    var https: String {
        get {
            if starts(with: "http://") {
                return replacingOccurrences(of: "http://", with: "https://")
            } else {
                return self
            }
        }
    }
}

extension URL {
    var https: URL? {
        get {
            return URL(string: absoluteString.https)
        }
    }
}
