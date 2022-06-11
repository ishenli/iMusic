//
//  String.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/10.
//
import Cocoa

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
