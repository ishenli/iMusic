//
//  SearchResultView.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/13.
//

import SwiftUI


struct SerachPagination: PaginationProtocol {
  func onChange(page: Int, pageSize: Int) {
    SearchViewModel.Shared.fetchWithPage(page: page - 1)
  }
}

struct SearchResultView: View {
  var keyword: String
  @StateObject var vm = SearchViewModel.Shared
  var body: some View {
    ZStack {
      VStack{
        VStack(alignment: .leading, spacing: 0){
          Header(title: "搜索结果：")
          HStack {
  //          各个平台
            HStack(alignment: .top) {
              Group{
                ForEach(vm.platformTabs) {tabItem in
                  Text(tabItem.tabName)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundColor(vm.platformSelected == tabItem.id ? Color.black : Color.gray)
                    .onTapGesture {
                      vm.platformTabClick(id: tabItem.id)
                    }
                }
              }.font(.system(size: 14))
            }
            Spacer()
  //          单曲、歌单
            HStack(alignment: .bottom) {
              Group{
                ForEach(vm.searchTypeTabs) {tabItem in
                  Text(tabItem.tabName)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .foregroundColor(vm.searchType.rawValue == tabItem.id ? Color.black : Color.gray)
                    .onTapGesture {
                      vm.searchTypeTabClick(type: tabItem.searchType)
                    }
                }
              }.font(.system(size: 14))
            }
          }.padding(.vertical, 5).padding(.leading, -10)
        }.padding(EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 40))

        VStack {
          if vm.isLoading {
            ProgressView()
          } else {
            if (vm.searchType == .songs) {
              PlaySongTable(tracks: vm.searchSongList)
            } else {
              PlayListTable(playList: vm.searchPlayList)
            }
            
            HStack {
              Spacer()
              Pagination(vm: SerachPagination())
            }.padding(.top, 10)
            
          }
          Spacer()
        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        
      }
      .background(.white)
      .frame( minWidth: 500,
              minHeight: 600)
      .task {
        await vm.fetch(keyword: keyword)
      }
      
      SidePlayList()
    }
  }
}

struct SearchResultView_Previews: PreviewProvider {
  static var previews: some View {
    SearchResultView(keyword: "gogo")
  }
}
