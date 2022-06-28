//
//  MusicPlatform.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import Foundation



struct PlatformSearchResult: SearchResultProtocol {
  var songs: [Track]
}

struct PlatformSearchPlayListResult {
  var playList: [SearchPlayList]
}

protocol AbstractMusicPlatform {
  func fetchRecommend() async -> [Rank]
  
  func fetchPlayList(_ id: Int) async -> Playlist?
  
  func search(keywords: String,
              page: Int,
              type: SearchType) async -> PlatformSearchResult?
  
  func songUrl(_ ids: [Int]) async -> [Song]
  
  
  func searchPlayList(keywords: String, page: Int) async -> PlatformSearchPlayListResult?
}


enum SearchType: Int {
  case none, songs, albums, artists, playlists
}

enum MusicPlatformEnum {
  case netease
  case kugou
  case qq
  case kuwo
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
  .init(name: MusicPlatformEnum.kuwo, title: "酷我", searchable: true, supportLogin: true, id: 2),
  .init(name: MusicPlatformEnum.qq, title: "QQ", searchable: true, supportLogin: true, id: 3),
]


func getPlatformById(id: Int) -> MusicPlatformMeta {
  if let foo = MusicPlatformList.first(where: {$0.id == id}) {
    return foo;
  } else {
    return MusicPlatformMeta.init(name: MusicPlatformEnum.unknown, title: "未知", searchable: false, supportLogin: false, id: 0)
  }
}

func getPlatformByName(name: MusicPlatformEnum) -> AbstractMusicPlatform {
  switch name {
  case MusicPlatformEnum.netease:
    return NetEaseMusic()
  case .kugou:
    return NetEaseMusic()
  case .qq:
    return QQMusic()
  case .unknown:
    print("unknown")
    return NetEaseMusic()
  case .kuwo:
    return KWMusic()
  }
}

func getPlatformInstance(id: Int) -> AbstractMusicPlatform {
  let matchPlatform = getPlatformById(id: id)
  return getPlatformByName(name: matchPlatform.name)
}


class MusicPlatform {
  static let Shared = MusicPlatform()
  
  func getSongsDetail(_ songs: [Track]) async -> [Song] {
    var rt:[Song] = []
    await songs.concurrentMap{ track in
      let song = await self.getSongDetail(track)
      rt.append(contentsOf: song)
    }

    return rt
  }
  
  
  func getSongDetail(_ song: Track) async -> [Song] {
    let platform = getPlatformByName(name: song.platform)
    
    let songs = await platform.songUrl([song.id])
    return songs
  }
  
  
  func fetchPlayList(playListId: Int, paltform: MusicPlatformEnum) async -> Playlist? {
    let PlatformIns = getPlatformByName(name: paltform)
    return await PlatformIns.fetchPlayList(playListId)
  }
  

  func search(keyword: String, id: Int, page: Int, searchType: SearchType) async -> PlatformSearchResult? {
    let PlatformIns = getPlatformInstance(id: id)
    let data = await PlatformIns.search(keywords: keyword, page: page, type: searchType);
    return data
  }
}

