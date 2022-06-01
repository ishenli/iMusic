//
//  Header.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/23.
//

import SwiftUI

struct Header: View {
  var title: String
  var body: some View {
      Text(title)
      .font(.system(size: 16, weight: .bold))
  }
}

struct Header_Previews: PreviewProvider {
  static var previews: some View {
    Header(title: "标题")
  }
}
