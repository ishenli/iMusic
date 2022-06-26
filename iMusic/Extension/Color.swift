//
//  Color.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/22.
//

import Foundation
import SwiftUI

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }
    
    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue:  Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
  
  static var black1: Color {
    return Color.init(hex: "000000")
  }
  
  static var gray1: Color {
    return Color.init(hex: "666666")
  }
  
  static var gray2: Color {
    return Color.init(hex: "FAFAFA")
  }
  
  static var gray3: Color {
    return Color.init(hex: "BBBBBB")
  }
  
  
  // 这个颜色来着 ant.design 的容器
  static var blue1: Color {
    return Color.init(hex: "7F9ABE")
  }
  
  static var blue2: Color {
    return Color.init(hex: "E6F7FF") // 容器
  }
  
  static var blue3: Color {
    return Color.init(hex: "91D5FF") // 边框
  }
  
  static var blue6: Color {
    return Color.init(hex: "1890FF") // 按钮
  }
}
