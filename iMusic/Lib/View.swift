//
//  View.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/11.
//

import Foundation
import SwiftUI


struct GrayColorStyleModifider: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor( Color.init(hex: "BBBBBB"))
  }
}

struct CursorStyleModifider: ViewModifier {
  func body(content: Content) -> some View {
    content
      .onHover { inside in
        if inside {
          NSCursor.pointingHand.push()
        } else {
          NSCursor.pop()
        }
      }
  }
}


  

extension View {
  func withGrayColorFormatting() -> some View {
    modifier(GrayColorStyleModifider())
  }
  func withCursorStyle() -> some View {
    modifier(CursorStyleModifider())
  }
}
