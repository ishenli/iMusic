//
//  KWCodaableObject.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/25.
//

import Foundation


class KWSong: NSObject, Decodable {
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
}


struct KWSearchResultJSON: Decodable {
  let code: Int
  let data: Data
  
  struct Data: Decodable {
    let list: [KWTrack]
  }
}

struct KWSearchPlayListJSON: Decodable {
  let code: Int
  let data: Data
  
  struct Data: Decodable {
    let list: [KWPlayList]
  }
  
  struct KWPlayList: Decodable {
    let img: String
    let total: String
    let uname: String
    let name: String
    let listencnt: String
    let id: String
  }
}


struct KWPlayListJSON: Decodable {
  let code: Int
  let data: Data
  
  struct Data: Decodable {
    let id: Int
    let uPic: String
    let img500: String
    let listencnt: Int
    let total: Int
    let name: String
    let tag: String
    let uname: String
    let info: String
    let musicList: [KWPlayList]
  }
  
  struct KWPlayList: Decodable {
    let pic: String
    let duration: Int
    let name: String
    let album: String
    let albumid: Int
    let albumpic: String
    let releaseDate: String
    let rid: Int
    let artistid: Int
    let artist: String
  }
}



class KWTrack: Decodable, TrackProtocol {
  var playable: Bool
  
  var platform: MusicPlatformEnum
  
  var album: Album
  
  
  typealias AlbumType = KWTrack.Album
  
  var index: Int
  
  var name: String
  
  
  var id: Int
  
  var artists: [ArtistProtocol]
  
  var duration: Int
  
  //  var song: SongProtocol?
  
  enum CodingKeys: String, CodingKey {
    case name, rid, duration, album, albumid, pubtime, artist, artistid, pic
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.name = try container.decode(String.self, forKey: .name)
    self.id = try container.decode(Int.self, forKey: .rid)
    
    
    let artist = try container.decode(String.self, forKey: .artist)
    let artistid = try container.decode(Int.self, forKey: .artistid)
    self.artists = [Artist(name: artist, id: artistid)]

    let albumname = try container.decode(String.self, forKey: .album)
    let albumid = try container.decode(String.self, forKey: .albumid)
    let pic = try container.decode(String.self, forKey: .pic)
    
    self.album = Album(name: albumname, id: Int(albumid)!, publishTime: "", picUrl: URL(string: pic))

    self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)!
    self.duration = self.duration * 1000 // 时长单位是秒，统一成毫秒
    
    self.index = -1
    self.platform = .kuwo
    self.playable = true
  }
  
  func toTrack() -> Track {
    let artists = self.artists.map { a in
      Track.ArtistType(name: a.name, id: a.id, picUrl: a.picUrl ?? "")
    }
    let album = Track.AlbumType(name: self.album.name, id: self.album.id, picUrl: self.album.picUrl,
                                publishTime: self.album.publishTime, artists: artists, size: self.album.size)
    return Track(name: self.name, id: self.id, platform: self.platform, artists: artists, album: album, duration: self.duration, playable: self.playable)
  }
  
  class Artist: ArtistProtocol {
    
    var name: String
    
    var id: Int
    
    var picUrl: String?
    
    var musicSize: Int?
    
    var albumSize: Int?
    
    var alias: [String]?
    
    var followed: Bool?
    
    required init(name: String, id: Int) {
      self.name = name
      self.id = id
    }
  }
  
  struct Album: AlbumProtocol {
    var index: Int?
    var artists: [KWTrack.Artist]?
    typealias ArtistType = Artist
    var name: String
    
    var id: Int
    var size: Int?
    var publishTime: String?
    var picUrl: URL?
  }
}
