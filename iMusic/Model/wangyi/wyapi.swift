//
//  netease.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/30.
//
import Foundation
import Cocoa
import Alamofire
import CryptoSwift


struct TopList: Decodable {
  let code: Int
  let list: [Playlist]
  
  struct Playlist: Decodable {
    let id: Int
    let name: String
    let description: String?
    let coverImgUrl: String
  }
}

enum RequestError: Error {
  case error(Error)
  case noData
  case errorCode((Int, String))
  case unknown
}

class NetEaseMusic : AbstractMusicPlatform {
  
  func searchPlayList(keywords: String, page: Int) async -> PlatformSearchPlayListResult? {
    return nil
  }
  
  
  
  let nmDeviceId: String
  let nmAppver: String
  let channel: NMChannel
  let nmSession: Session
  var reachabilityManager: NetworkReachabilityManager?
  
  init() {
    nmDeviceId = "\(UUID().uuidString)|\(UUID().uuidString)"
    nmAppver = "1.5.10"
    channel = NMChannel(nmDeviceId, nmAppver)
    
    let session = Session(configuration: .default)
    let cookies = ["deviceId",
                   "os",
                   "appver",
                   "MUSIC_U",
                   "__csrf",
                   "ntes_kaola_ad",
                   "channel",
                   "__remember_me",
                   "NMTID",
                   "osver"]
    
    session.sessionConfiguration.httpCookieStorage?.cookies?.filter {
      !cookies.contains($0.name)
    }.forEach {
      session.sessionConfiguration.httpCookieStorage?.deleteCookie($0)
    }
    
    
    ["deviceId": nmDeviceId,
     "os": "osx",
     "appver": nmAppver,
     "channel": "netease",
     // 临时添加
     "MUSIC_U": "687d56c651f440af825e90a782b55089b6390486f0bae018899e7ee605727eb57c4bb615af8ed51c68eff3e0cbbdcf59136f3bf144faa3b4a18228ec15c68b1104e1557b3b6e0e0b56b5785f932ffd38",
     "osver": "Version%2010.16%20(Build%2020G165)",
    ].compactMap {
      HTTPCookie(properties: [
        .domain : ".music.163.com",
        .name: $0.key,
        .value: $0.value,
        .path: "/"
      ])
    }.forEach {
      session.sessionConfiguration.httpCookieStorage?.setCookie($0)
    }
    
    session.sessionConfiguration.headers = HTTPHeaders.default
    session.sessionConfiguration.headers.update(name: "user-agent", value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16) AppleWebKit/605.1.15 (KHTML, like Gecko)")
    nmSession = session
  }
  
  
  func eapiRequest<T: Decodable>(
    _ url: String,
    _ params: [String: Any],
    _ resultType: T.Type,
    shouldDeSerial: Bool = false) async throws -> T {
      
      var data: Data = Data()
      do {
        let p = try channel.serialData(params, url: url)
        let dataTask = nmSession.request(url, method: .post, parameters: ["params": p]).serializingData()
        let re = await dataTask.response
        
        guard re.data != nil else {
          Log.error(RequestError.noData)
          throw RequestError.noData
        }
        data = re.data!
        
        if shouldDeSerial {
          if let d = try self.channel.deSerialData(data.toHexString(), split: false)?.data(using: .utf8) {
            data = d
          } else {
            throw RequestError.noData
          }
        }
        return try JSONDecoder().decode(resultType.self, from: data)
        
      } catch let error where error is ServerError {
        Log.error(error)
        throw RequestError.error(error)
      } catch let error {
        Log.error(error)
        Log.error(data)
        throw RequestError.error(error)
      }
    }
  
  func apiRequest<T: Decodable>(
    _ url: String,
    _ params: [String: Any],
    _ resultType: T.Type) async throws -> T {
      
      do {

        let dataTask = nmSession.request(url, method: .post, parameters: params).serializingData()
        let re = await dataTask.response
        
        guard var data = re.data else {
          Log.error(RequestError.noData)
          throw RequestError.noData
        }
        data = re.data!
        
        return try JSONDecoder().decode(resultType.self, from: data)
        
      } catch let error where error is ServerError {
        Log.error(error)
        throw RequestError.error(error)
      } catch let error {
        Log.error(error)
        throw RequestError.error(error)
      }
    }
  
  func fetchRecommend(page: Int) async -> [Rank] {
    let rankList: [Rank] = [];
    do {
      let data = try await self.eapiRequest(
        "https://music.163.com/eapi/v1/discovery/recommend/resource",
        [:],
        RecommendResource.self)
      
      return data.recommend.map {
        Rank.init(name: $0.name, imageUrl: $0.picUrl.absoluteString, id: $0.id, theme: 0)
      }
    } catch {
//      print("Fetching fetchRecommend failed with error \(error)")
      return rankList
    }
    
  }
  
  func fetchPlayList(_ id: Int) async -> Playlist? {
    struct Result: Decodable {
      let playlist: WYPlaylist
      let privileges: [Track.Privilege]?
      let code: Int
    }
    
    do {
      
      let re = try await self.eapiRequest(
        "https://music.163.com/eapi/v3/playlist/detail",
        ["id": id,
         "n": 0,
         "s": 0,
         "t": -1],
        Result.self)
      
      //      let re:Result = load("wangyi/playlist");
      let playlist = re.playlist;
      
      // 每首歌请求详情
      guard let ids = re.playlist.trackIds?.map({ $0.id }) else {
        return nil
      }
      let list = stride(from: 0, to: ids.count, by: 500).map {
        Array(ids[$0..<($0+500 >= ids.count ? ids.count : $0+500)])
      }
      
      
      let rt:[[WYTrack]] = await list.concurrentMap{ ids in
        let tracker = await self.songDetail(ids);
        return tracker
      }
      
      let tracks = rt.flatMap {
        return $0.map { t in
          t.toTrack()
        }
      }
      var pl = playlist.toPlaylist(p1: playlist)
      pl.tracks = tracks
      return pl
    } catch {
      print("Fetching fetchRecommend failed with error \(error)")
      return nil;
    }
  }
  
  func songDetail(_ ids: [Int]) async -> [WYTrack] {
    struct Result: Decodable {
      let songs: [WYTrack]
      let code: Int
      let privileges: [WYTrack.Privilege]
    }
    
    let c = "[" + ids.map({ "{\"id\":\"\($0)\", \"v\":\"\(0)\"}" }).joined(separator: ",") + "]"
    
    let p = [
      "c": c
    ]
    do {
      let data = try await self.eapiRequest(
        "https://music.163.com/eapi/v3/song/detail",
        p,
        Result.self)
      
      let re = data.songs
      let p = data.privileges
      re.enumerated().forEach {
        guard $0.element.id == p[$0.offset].id else { return }
        re[$0.offset].privilege = p[$0.offset]
      }
      return re
    } catch {
      print("Fetching fetchRecommend failed with error \(error)")
    }
    return []
  }
  
  
  func songUrl(_ ids: [Int]) async -> [Song]  {
    struct Result: Decodable {
      let data: [WYSong]
      let code: Int
    }
    
    let p: [String : Any] = [
      "ids": ids,
      "br": 99999,
      "e_r": true
    ]

    
    do {
      let res = try await self.eapiRequest(
        "https://music.163.com/eapi/song/enhance/player/url",
        p,
        Result.self,
        shouldDeSerial: true)
      let data = res.data.map { WYSong in
        return Song(id: WYSong.id, url: WYSong.url, platform: .netease)
      }
      
      return data
    } catch {
      return []
    }
    
  }
  
  
  func search(keywords: String, page: Int, type: SearchType) async -> PlatformSearchResult? {
  // 参考listen1的接口实现
    var p: [String: Any] = [
      "s": keywords,
      "limit": 20,
      "offset": page * 20,
      "total": true
    ]
    
    
    var u = "https://music.163.com/eapi/search/pc"
    
    // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
    switch type {
    case .songs:
      p["type"] = 1
      u = "https://music.163.com/api/search/pc"
    case .albums:
      p["type"] = 10
    case .artists:
      p["type"] = 100
    case .playlists:
      p["type"] = 1000
    default:
      p["type"] = 0
    }
    
    do {
      let res = try await self.apiRequest(u,p,SearchResult.self);
      return res.result.toViewModel()
    } catch {
      print("Fetching search failed with error \(error)")
      return nil
    }
  }

  
  
  
}
