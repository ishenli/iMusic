//
//  domain.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/18.
//

import Foundation
import AVFoundation
import AppKit

protocol PlaylistProtocol {
  associatedtype TrackType
  var subscribed: Bool { get }
  var coverImgUrl: URL { get }
  var playCount: Int { get }
  var name: String { get set }
  var trackCount: Int { get set }
  var description: String? { get set }
  var tags: [String]? { get set }
  var id: Int { get set }
  var tracks: [TrackType] { get set }
  var trackIds: [TrackIdProtocol]? { get set }
  var creator: CreatorProtocol? { get set }
  var createTime: Int { get set }
  var createTimeStr: String? { get set }
}

protocol CreatorProtocol {
    var nickname: String { get set }
    var userId: Int { get set }
}

protocol TrackIdProtocol {
  var id: Int { get set }
  var v: Int { get set }
}

protocol TrackProtocol {
  associatedtype ArtistType
  associatedtype AlbumType
  var name: String  { get set }
  var id: Int { get set }
  var index: Int { get set }
  var artists: [ArtistType] { get set }
  var album: AlbumType { get set }
  var duration: Int { get set }
  var platform: MusicPlatformEnum { get }
  var playable: Bool { get }
//  var song: SongProtocol? { get set }
}


// 特权
protocol PrivilegeProtocol {
  var id: Int { get set }
  var fee: Int{ get set }
  var payed: Int{ get set }
  var st: Int{ get set }
  var maxbr: Int{ get set }
  var pl: Int{ get set }
  var flag: Int{ get set }
  var dl: Int{ get set }
}

protocol AlbumProtocol {
  associatedtype ArtistType
  
  var name: String { get set }
  var picUrl: URL? { get set }
  var id: Int { get set }
  var index: Int? { get set }
  var artists: [ArtistType]? { get set }
}


protocol ArtistProtocol {
  var name: String { get set }
  var id: Int { get set }
  var picUrl: String? { get set }
  var musicSize: Int? { get set }
  var albumSize: Int? { get set }
  var alias: [String]? { get set }
  var followed: Bool? { get set }
}



protocol SongProtocol {
  var id: Int { get set }
  var url: URL { get set }
  var br: Int { get set }
  var type: String { get set }
  var payed: Int { get set }
  var level: String? { get set }
  var encodeType: String? { get set }
  var md5: String { get set }
  var expi: Int { get set }
  
  var urlValid: Bool { get set }
  
}

// SearchResult

protocol SearchResultProtocol {
  associatedtype SongType
  var songs: [SongType] { get set }
}




extension Array where Element: TrackProtocol {
  func initIndexes() -> Void {
    var tracks = self
    tracks.enumerated().forEach {
      tracks[$0.offset].index = $0.offset
    }
//    return tracks
  }
}
