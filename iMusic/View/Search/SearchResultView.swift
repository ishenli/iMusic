//
//  SearchResultView.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/13.
//

import SwiftUI

struct SearchResultView: View {
  var keyword: String
  @StateObject var vm = SearchViewModel.Shared
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Header(title: "搜索结果：")
        HStack {
          Group{
            ForEach(vm.tabItems) {tabItem in
              Text(tabItem.tabName)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundColor(vm.tabSelect == tabItem.id ? Color.black : Color.gray)
                .onTapGesture {
                  vm.tabClick(id: tabItem.id)
                }
            }
          }.font(.system(size: 14))
          Spacer()
        }.padding(.vertical, 5).padding(.leading, -10)
        if vm.isLoading {
          ProgressView()
        } else {
          
        }
        Spacer()
      }
      .padding(40)
      .frame( minWidth: 500,
              minHeight: 600)
    }.task {
      await vm.fetch(keyword: keyword)
    }
  }
}

struct SearchResultView_Previews: PreviewProvider {
  static var previews: some View {
    SearchResultView(keyword: "gogo")
  }
}
