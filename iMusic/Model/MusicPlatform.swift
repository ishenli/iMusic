//
//  MusicPlatform.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import Foundation

protocol AbstractMusicPlatform {
  func fetchRecommend() async -> [Rank]
  func fetchPlayList(_ id: Int) async -> Playlist?
//  func fetchSong()
}


enum MusicPlatformEnum {
  case netease
  case kugou
  case qq
  case unknown
}

struct MusicPlatformMeta {
  var name: MusicPlatformEnum
  var title: String
  var searchable: Bool
  var supportLogin: Bool
  var id: Int
}

let MusicPlatformList: [MusicPlatformMeta]  = [
  .init(name: MusicPlatformEnum.netease, title: "网易", searchable: true, supportLogin: true, id: 1),
  .init(name: MusicPlatformEnum.kugou, title: "酷狗", searchable: true, supportLogin: true, id: 2),
  .init(name: MusicPlatformEnum.qq, title: "QQ", searchable: true, supportLogin: true, id: 3),
]


func getPlatformById(id: Int) -> MusicPlatformMeta {
  if let foo = MusicPlatformList.first(where: {$0.id == id}) {
    return foo;
  } else {
    return MusicPlatformMeta.init(name: MusicPlatformEnum.unknown, title: "未知", searchable: false, supportLogin: false, id: 0)
  }
}

func getPlatformInstance(id: Int) -> AbstractMusicPlatform {
  let matchPlatform = getPlatformById(id: id)
  switch matchPlatform.name {
    case MusicPlatformEnum.netease:
    return NetEaseMusic()
  case .kugou:
    print("kugou")
    return NetEaseMusic()
  case .qq:
    print("qq")
    return NetEaseMusic()
  case .unknown:
    print("unknown")
    return NetEaseMusic()
  }
}
