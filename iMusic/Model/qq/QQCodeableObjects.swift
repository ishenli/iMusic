//
//  QQCodeableObjects.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/18.
//

import Foundation


struct QQSearchResult: Decodable {
  let songs: [QQTrack]
  let albums: [QQTrack.Album]
  let artists: [QQTrack.Artist]
  
  let songCount: Int
  let albumCount: Int
  let artistCount: Int
  let playlistCount: Int
}


struct QQSearchResultJSON: Decodable {
  let code: Int
  let data: Data
  
  struct Data: Decodable {
    let song: Song
  }
  struct Song: Decodable {
    let list: [QQTrack]
  }
}


class QQTrack: Decodable, TrackProtocol {
  var playable: Bool
  
  var platform: MusicPlatformEnum
  
  var album: Album
  
  
  typealias AlbumType = QQTrack.Album
  
  var index: Int
  
  var name: String
  
  
  var id: Int
  
  var artists: [ArtistProtocol]
  
  var duration: Int
  
  var durationStr: String
  
  //  var song: SongProtocol?
  
  enum CodingKeys: String, CodingKey {
    case songname, songid, singer, nt, albumname, albumid, pubtime
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.name = try container.decode(String.self, forKey: .songname)
    self.id = try container.decode(Int.self, forKey: .songid)
    self.artists = try container.decode([Artist].self, forKey: .singer)
    let albumname = try container.decode(String.self, forKey: .albumname)
    let albumid = try container.decode(Int.self, forKey: .albumid)
    let pubtime = try container.decode(Int.self, forKey: .pubtime)
    self.album = Album(name: albumname, id: albumid, publishTime: String(pubtime))
    self.duration = try container.decodeIfPresent(Int.self, forKey: .nt)!
    self.durationStr = Double(self.duration).duration2Date()
    self.index = -1
    self.platform = .qq
    self.playable = true
  }
  
  func toTrack() -> Track {
    let artists = self.artists.map { a in
      Track.ArtistType(name: a.name, id: a.id, picUrl: a.picUrl ?? "")
    }
    let album = Track.AlbumType(name: self.album.name, id: self.album.id, picUrl: self.album.picUrl,
                                publishTime: self.album.publishTime, artists: artists, size: self.album.size)
    return Track(name: self.name, id: self.id, platform: .qq, artists: artists, album: album, duration: self.duration, playable: self.playable)
  }
  
  class Artist: ArtistProtocol, Decodable {
    
    var name: String
    
    var id: Int
    
    var picUrl: String?
    
    var musicSize: Int?
    
    var albumSize: Int?
    
    var alias: [String]?
    
    var followed: Bool?
    
    enum CodingKeys: String, CodingKey {
      case name, id
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(String.self, forKey: .name)
      self.id = try container.decode(Int.self, forKey: .id)
    }
  }
  
  struct Album: AlbumProtocol, Decodable {
    
    var index: Int?
    
    var artists: [QQTrack.Artist]?
    
    typealias ArtistType = Artist
    var name: String
    
    var id: Int
    var size: Int?
    var publishTime: String?
    var picUrl: URL?
  }
}


struct QQCategoryFilter: Decodable {
  var code: Int
  var data: CategoryFilterData
  
  struct CategoryFilterData: Decodable {
    var categories: [CategoryGrooupItem]
  }
  struct CategoryGrooupItem: Decodable {
    var categoryGroupName: String
    var items: [CategoryFilterItem]
    var usable: Int
  }
  
  struct CategoryFilterItem: Decodable {
    var categoryId: Int
    var categoryName: String
    var usable: Int
  }
}
