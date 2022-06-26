//
//  Message.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/26.
//

import SwiftUI

struct MessageView: View {
  var text: String = "default"
  var body: some View {
    Text(text)
      .foregroundColor(Color.black1)
      .padding()
      .frame(minWidth: 360)
      .background(Color.blue2)
      .border(Color.blue3, width: 2)
      .cornerRadius(2)
      
  }
}

struct Message_Previews: PreviewProvider {
  static var previews: some View {
    MessageView()
  }
}
