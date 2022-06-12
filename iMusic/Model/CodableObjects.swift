//
//  CodableObjects.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/4/10.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Foundation
import AVFoundation
import AppKit

struct ServerError: Decodable, Error {
  let code: Int
  let msg: String?
  let message: String?
}


struct Playlist: Decodable {
  let subscribed: Bool
  let coverImgUrl: URL
  let playCount: Int
  let name: String
  let trackCount: Int
  let description: String?
  let tags: [String]?
  let id: Int
  var tracks: [Track]
  let trackIds: [TrackId]?
  let creator: Creator?
  let createTime: Int
  var createTimeStr: String?
  
  struct TrackId: Decodable {
    let id: Int
    let v: Int
    
  }
  
  struct Creator: Decodable {
    let nickname: String
    let userId: Int
    let avatarUrl: URL
  }
}

class Track: NSObject, Decodable, Identifiable {
  let name: String
  let secondName: String
  let id: Int
  let artists: [Artist]
  let album: Album
  let duration: Int
  let durationStr: String
  var song: Song?
  
  let pop: Int
  
  var index = -1
  
  lazy var artistsString: String = {
      return artists.artistsString()
  }()
  
  // privileges - st
  // playable st == 0
  var playable: Bool {
    get {
      if let p = privilege {
        return p.status == .playable
      } else {
        return false
      }
    }
  }
  
  var privilege: Privilege?
  
//  var from: (type: SidebarViewController.ItemType, id: Int, name: String?) = (.none, 0, nil)
  
  dynamic var isCurrentTrack = false
  dynamic var isPlaying = false
  
  struct Privilege: Decodable {
    let id: Int
    let fee: Int
    let payed: Int
    let st: Int
    let maxbr: Int
    let pl: Int
    let flag: Int
    let dl: Int
    
    enum Status {
      case needToBuy
      case checkPrivilege
      case copyrightProtection
      case needToDownload
      case playable
    }
    
    var status: Status {
      get {
        // function cDV1x(d3x)
        // l3x.qP9G = function(bn4r, action)
        
        if pl <= 0 && (fee > 63 || flag > 4095) {
          return .checkPrivilege
        } else if st < 0 {
          return .copyrightProtection
        } else if fee > 0 && fee != 8 && payed == 0 && pl <= 0 {
          return .needToBuy
        } else if fee == 16 || fee == 4 && (flag & 2048) != 0 {
          return .needToDownload
        } else if (fee == 0 || payed == 1) && pl > 0 && dl == 0 {
          return .playable
        } else if pl == 0 && dl == 0 {
          return .copyrightProtection
        } else {
          return .playable
        }
      }
    }
  }
  
  class Album: NSObject, Decodable {
    let name: String
    let id: Int
    var picUrl: URL?
    let des: String?
    let publishTime: Int
    let artists: [Artist]?
    let size: Int
    
    func formattedTime() -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: .init(timeIntervalSince1970: .init(publishTime / 1000)))
    }
    
    enum CodingKeys: String, CodingKey {
      case name, id, picUrl, des = "description", publishTime, artists, size
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.name = try container.decode(String.self, forKey: .name)
      self.id = try container.decode(Int.self, forKey: .id)
      if let str = try container.decodeIfPresent(String.self, forKey: .picUrl) {
        self.picUrl = URL(string: str.https)
      } else {
        self.picUrl = nil
      }
      
      self.des = try container.decodeIfPresent(String.self, forKey: .des)
      self.publishTime = try container.decodeIfPresent(Int.self, forKey: .publishTime) ?? 0
      self.artists = try container.decodeIfPresent([Artist].self, forKey: .artists)
      self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 0
    }
  }
  

  class Artist: NSObject, Decodable {
    let name: String
    let id: Int
    var picUrl: String?  // 640 x 520
    let musicSize: Int?
    let albumSize: Int?
    let alias: [String]?
    let followed: Bool?
  }
  
  enum CodingKeys: String, CodingKey {
    case name, id, pop, artists, album, duration, privilege
  }
  
  enum SortCodingKeys: String, CodingKey {
    case artists = "ar", album = "al", duration = "dt"
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let sortContainer = try decoder.container(keyedBy: SortCodingKeys.self)
    let fullName = try container.decode(String.self, forKey: .name)
    if fullName.contains("("), fullName.last == ")" {
      name = fullName.subString(to: "1")
      secondName = "(" + fullName.subString(from: "1", to: ")") + ")"
    } else {
      name = fullName
      secondName = ""
    }
    self.id = try container.decode(Int.self, forKey: .id)
    
    self.pop = try container.decodeIfPresent(Int.self, forKey: .pop) ?? 0
    self.privilege = try container.decodeIfPresent(Privilege.self, forKey: .privilege)
    
    self.artists = try container.decodeIfPresent([Artist].self, forKey: .artists) ?? sortContainer.decode([Artist].self, forKey: .artists)
    self.album = try container.decodeIfPresent(Album.self, forKey: .album) ?? sortContainer.decode(Album.self, forKey: .album)
    self.duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? sortContainer.decode(Int.self, forKey: .duration)
    self.durationStr = Double(self.duration).duration2Date() 
  }
}

extension Array where Element: Track {
  func initIndexes() -> [Track] {
    let tracks = self
    tracks.enumerated().forEach {
      tracks[$0.offset].index = $0.offset
    }
    return tracks
  }
}


class Song: NSObject, Decodable {
  let id: Int
  let url: URL
  // 320kbp  =>  320,000
  let br: Int
  let type: String
  let payed: Int
  let level: String?
  let encodeType: String?
  let md5: String
  let expi: Int // useless
  
  
  var urlValid: Bool {
    get {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyyMMddHHmmss"
      
      let pcs = url.pathComponents
      guard pcs.count > 2,
            pcs[1].count == 14,
            let date = formatter.date(from: pcs[1]),
            let now = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) else {
        return false
      }
      
      return now < date
    }
  }
}

struct RecommendResource: Decodable {
  let code: Int
  let recommend: [Playlist]
  
  struct Playlist: Decodable {
    let id: Int
    let name: String
    let copywriter: String
    let picUrl: URL
    let trackCount: Int
    let playcount: Int
    let alg: String
  }
}

struct RecommendSongs: Decodable {
  let code: Int
  let recommend: [Track]
}

struct LyricResult: Decodable {
  let code: Int
  let lrc: Lrc?
  let tlyric: Lrc?
  let nolyric: Bool?
  let uncollected: Bool?
  
  struct Lrc: Decodable {
    let version: Int
    let lyric: String?
  }
}

struct SearchSuggest: Decodable {
  let code: Int
  let result: Result
  
  struct Result: Decodable {
    let songs: [Song]?
    let albums: [Album]?
    let mvs: [MV]?
    let artists: [Artist]?
    let playlists: [Playlist]?
    let order: [String]?
  }
  
  struct Song: Decodable {
    let name: String
    let id: Int
    let album: Album
    let artists: [Artist]
  }
  
  struct Album: Decodable {
    let name: String
    let id: Int
    let artist: Artist
  }
  
  struct MV: Decodable {
    let name: String
    let id: Int
    let cover: URL
  }
  
  struct Artist: Decodable {
    let name: String
    let id: Int
    let img1v1Url: URL
  }
  
  struct Playlist: Decodable {
    let name: String
    let id: Int
    let coverImgUrl: URL
  }
}


struct AlbumResult: Decodable {
  let songs: [Track]
  let code: Int
  let album: Track.Album
}

struct ArtistAlbumsResult: Decodable {
  let code: Int
  let artist: Track.Artist
  let hotAlbums: [Track.Album]
}


struct ArtistResult: Decodable {
  let code: Int
  let artist: Track.Artist
  let hotSongs: [Track]
}

struct SearchResult: Decodable {
  let code: Int
  let result: Result
  
  class Result: NSObject, Decodable {
    let songs: [Track]
    let albums: [Track.Album]
    let artists: [Track.Artist]
    let playlists: [Playlist]
    
    let songCount: Int
    let albumCount: Int
    let artistCount: Int
    let playlistCount: Int
    
    enum CodingKeys: String, CodingKey {
      case songs, songCount, albums, albumCount, artists, artistCount, playlists, playlistCount
    }
    
    required init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      songs = try container.decodeIfPresent([Track].self, forKey: .songs) ?? []
      albums = try container.decodeIfPresent([Track.Album].self, forKey: .albums) ?? []
      artists = try container.decodeIfPresent([Track.Artist].self, forKey: .artists) ?? []
      playlists = try container.decodeIfPresent([Playlist].self, forKey: .playlists) ?? []
      
      songCount = try container.decodeIfPresent(Int.self, forKey: .songCount) ?? 0
      albumCount = try container.decodeIfPresent(Int.self, forKey: .albumCount) ?? 0
      artistCount = try container.decodeIfPresent(Int.self, forKey: .artistCount) ?? 0
      playlistCount = try container.decodeIfPresent(Int.self, forKey: .playlistCount) ?? 0
    }
  }
}

struct NUserProfile: Decodable {
  let userId: Int
  let nickname: String
  let avatarUrl: String
}


extension Array where Element: Track.Artist {
    func artistsString() -> String {
        return self.map {
            $0.name
            }.joined(separator: " / ")
    }
}
