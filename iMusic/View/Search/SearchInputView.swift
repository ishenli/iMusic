//
//  SearchInput.swift
//  iMusic
//
//  Created by michael.sl on 2022/7/4.
//

import SwiftUI

struct SearchInputView: View {
  @State private var searchKeyword: String = ""

  @Environment(\.StackNavigationPush) var StackNavigationPush
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
      TextField(
        "Search",
        text: $searchKeyword
      )
      .onSubmit {
        StackNavigationPush(AnyView(SearchResultView(keyword: searchKeyword)), nil)
      }
      .frame(height: 28)
      .textFieldStyle(PlainTextFieldStyle())
      if searchKeyword != "" {
        Image(systemName: "xmark.circle.fill").onTapGesture {
          searchKeyword = ""
        }
      }
      
    }
    .padding([.horizontal], 8)
    .background(Color.init(hex:"C7C5CA"))
    .cornerRadius(4)
    .padding([.horizontal], 10)
  }
}

struct SearchInput_Previews: PreviewProvider {
  static var previews: some View {
    SearchInputView()
  }
}
