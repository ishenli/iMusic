//
//  Track.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/24.
//

import Foundation

class Track: NSObject, Identifiable, TrackProtocol {
  
  
  var name: String
  
  var id: Int
  
  var index: Int
  
  var artists: [Artist]
  
  var album: Album
  
  var duration: Int
  
  var durationStr: String
  
  var song: Song?
  
  typealias ArtistType = Artist
  
  typealias AlbumType = Album
  
  var privilege: Privilege?
  
  var platform: MusicPlatformEnum
  
  
  dynamic var isCurrentTrack = false
  dynamic var isPlaying = false
  
  var playable: Bool {
    get {
      if let p = privilege {
        return p.status == .playable
      }
      return true
    }
  }
  
  lazy var artistsString: String = {
      return artists.artistsString()
  }()
  
  
  init(name:String, id: Int, platform:MusicPlatformEnum, artists: [Artist], album: Album, duration: Int) {
    self.name = name;
    self.id = id
    self.platform = platform
    self.artists = artists
    self.album = album
    self.duration = duration
    self.durationStr = Double(self.duration).duration2Date()
    self.index = -1
  }
  
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
}


class Artist: ArtistProtocol {
  var name: String
  
  var id: Int
  
  var picUrl: String?
  
  var musicSize: Int?
  
  var albumSize: Int?
  
  var alias: [String]?
  
  var followed: Bool?
  
  init(name:String, id: Int, picUrl: String) {
    self.name = name;
    self.id = id
    self.picUrl = picUrl
  }
  
}

class Album: AlbumProtocol {
  var name: String
  
  var picUrl: URL?
  
  var id: Int
  
  var publishTime: String?
  
  var size: Int?
  
  var index: Int?
  
  var artists: [Artist]?
  
  typealias ArtistType = Artist
  
  init(name:String, id: Int, picUrl: URL?, publishTime: String?, artists: [Artist], size: Int?) {
    self.name = name;
    self.id = id
    self.picUrl = picUrl ?? URL(string: "https://y.qq.com/music/photo_new/T002R300x300M000004MkHVG16Bto6_2.jpg?max_age=2592000")
    self.publishTime = publishTime
    self.artists = artists
    self.size = size ?? 0
  }
  
}

class Song: NSObject {
  let id: Int
  let url: URL
  let platform: MusicPlatformEnum

  // 320kbp  =>  320,000
//  let br: Int
//  let type: String
//  let payed: Int
//  let level: String?
//  let encodeType: String?
//  let md5: String
  
  init(id: Int, url: URL, platform: MusicPlatformEnum) {
    self.id = id
    self.url = url
    self.platform = platform
//    self.br = br ?? 0
//    self.type = type ?? ""
//    self.payed = payed ?? 0
//    self.level = level ?? ""
  }
  
  var urlValid: Bool {
    get {
      
      if self.platform != MusicPlatformEnum.netease {
        return true
      }
      
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

extension Array where Element: Track {
  func initIndexes() -> [Track] {
    let tracks = self
    tracks.enumerated().forEach {
      tracks[$0.offset].index = $0.offset
    }
    return tracks
  }
}



extension Array where Element: Artist {
    func artistsString() -> String {
        return self.map {
            $0.name
            }.joined(separator: " / ")
    }
}
