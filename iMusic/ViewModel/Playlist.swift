//
//  Playlist.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/24.
//

import Foundation



struct TrackId: Decodable {
  let id: Int
  let v: Int
  
}

struct Creator: Decodable {
  let nickname: String
  let userId: Int
  let avatarUrl: URL?
}


struct SearchPlayList: Identifiable {
  let id: Int
  let picUrl: URL
  let playCount: Int // 播放次数
  let name: String // 标题
  let Creator: Creator
  let trackCount: Int // 歌曲数
  var index: Int
}

struct Playlist {
  let subscribed: Bool
  let coverImgUrl: URL
  let playCount: Int
  var name: String
  let trackCount: Int
  let description: String?
  let tags: [String]?
  let id: Int
  var tracks: [Track]
  let trackIds: [TrackId]?
  let creator: Creator?
  let createTime: Int
  var createTimeStr: String?
}


extension Array where Element == SearchPlayList {
  func initIndexes() -> [SearchPlayList] {
    var tracks = self
    tracks.enumerated().forEach {
      tracks[$0.offset].index = $0.offset
    }
    return tracks
  }
}
