//
//  Rank.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/22.
//

import Foundation
import Alamofire


//
//final class Rank {
//  let title: String
//  var isChecked: Bool
//  init(title: String, isChecked: Bool) {
//    self.title = title
//    self.isChecked = isChecked
//  }
//}

struct Rank : Hashable, Identifiable, Codable {
  let name, imageUrl: String
  let id, theme: Int
}

struct TabItems: Hashable, Identifiable {
  let tabName: String
  let id: Int
}


//MusicPlatformConfig[MusicPlatform.netease]!.title,
//MusicPlatformConfig[MusicPlatform.kugou]!.title,
//MusicPlatformConfig[MusicPlatform.qq]!.title,

class RankViewModel: ObservableObject {
  @Published var isLoading = true
  @Published var ranks = [Rank]()
  
  @Published var tabSelect: Int = MusicPlatformList[0].id
  @Published var tabItems:[TabItems] = MusicPlatformList.map { MusicPlatformMeta in
    return TabItems.init(tabName: MusicPlatformMeta.title, id: MusicPlatformMeta.id)
  }

  @MainActor
  func fetch() async {
//    var rankList: [Rank] = [];
//    let data = await Kugou().fetchRecommand();
//
//    isLoading = false;
//    self.ranks = data;
//    debugPrint("isLoading", data)
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
    let data = await PlatformIns.fetchRecommend();
    isLoading = false
    ranks = data;
  }
}
