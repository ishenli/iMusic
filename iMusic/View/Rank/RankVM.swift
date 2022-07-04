//
//  Rank.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/22.
//

import Foundation
import Alamofire


struct Rank : Hashable, Identifiable, Codable {
  let name, imageUrl: String
  let id, theme: Int
}

struct TabItems: Hashable, Identifiable {
  let tabName: String
  let tag: MusicPlatformEnum
  let id: Int
}

class RankViewModel: ObservableObject {
  static let Shared: RankViewModel = RankViewModel()
  
  @Published var isLoading = true
  @Published var ranks = [Rank]()
  
  @Published var tabSelect: MusicPlatformEnum = .netease

  @Published var tabItems:[TabItems] = MusicPlatformList.map { MusicPlatformMeta in
    return TabItems.init(tabName: MusicPlatformMeta.title, tag: MusicPlatformMeta.name, id: MusicPlatformMeta.id)
  }

  @MainActor
  func fetch() async {
    await self.loadPlatformPlayLists(platformId: tabSelect)
  }
  
  
  func platformTabClick(id: MusicPlatformEnum) -> Void {
    tabSelect = id;
    Task {
      await self.loadPlatformPlayLists(platformId: id)
    }
  }
  
  @MainActor
  func loadPlatformPlayLists(platformId: MusicPlatformEnum) async {
    let data = await MusicPlatform.Shared.fetchRecommend(platformId: platformId, page: 1)
    isLoading = false
    ranks = data;
  }
}
