//
//  SearchVM.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/13.
//

import Foundation



class SearchViewModel: ObservableObject {
  static let Shared: SearchViewModel = SearchViewModel()
  private keyword: String
  
  @Published var isLoading = true
  @Published var ranks = [Rank]()
  
  @Published var tabSelect: Int = MusicPlatformList[0].id
  @Published var tabItems:[TabItems] = MusicPlatformList.map { MusicPlatformMeta in
    return TabItems.init(tabName: MusicPlatformMeta.title, id: MusicPlatformMeta.id)
  }

  @MainActor
  func fetch(keyword: String) async {
    self.keyword = keyword
    await self.loadPlatformPlayLists(id: tabSelect)
  }
  
  
  func tabClick(id: Int) -> Void {
    tabSelect = id;
    Task {
      await self.loadPlatformPlayLists(id: id)
    }
  }
  
  @MainActor
  func loadPlatformPlayLists(id: Int) async {
    let PlatformIns = getPlatformInstance(id: id)
    let data = await PlatformIns.search(self.keyword, limit: 10, page: 1, type: SearchResultType.artists)();
    isLoading = false
    ranks = data;
  }
}
