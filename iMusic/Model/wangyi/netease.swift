//
//  netease.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/30.
//

import Cocoa
import Alamofire


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
  
  func eapiParams() -> Dictionary<String, String>{
    var base = ["params": "7n4tUPUqk8uHDUhRZhRGStkKzSWJm3Kp2guAQk3Vx2g=", "encSecKey":
          "d9966d03ac266f1aad8ace9ba90898de6ce5c852386c1b50e9d098f8040407adabbfcbd15776e00d55deb8dbac219a5b85a872422066f23189ea3b2761292c5969d9f194afa381483477cc2c25d7bdf385dcb1f8625076217cc71f69b7ccd6025359acd30c9e99d03a12e65194b8f3830d9cb0ee11603f5c49d9bcb6881f0048"];
    return base;
  }
  
  func eapiRequest<T: Decodable>(
    _ url: String,
    _ params: [String: Any],
    _ resultType: T.Type,
    shouldDeSerial: Bool = false) async throws -> T {
      
      do {
        let p = try channel.serialData(params, url: url)
//        let dataTask = nmSession.request(url, method: .post, parameters: ["params": p]).serializingData()
        let dataTask = nmSession.request(url, method: .post, parameters: params).serializingData()
        let re = await dataTask.response
        
        print(re)
        guard var data = re.data else {
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
        throw RequestError.error(error)
      }
    }
  
  func fetchRecommend() async -> [Rank] {
    let rankList: [Rank] = [];
    do {
      let data = try await self.eapiRequest(
        "https://music.163.com/weapi/toplist/detail",
        self.eapiParams(),
        TopList.self)
      
      return data.list.map {
        Rank.init(name: $0.name, imageUrl: $0.coverImgUrl, id: $0.id, theme: 0)
      }
    } catch {
      print("Fetching toplist failed with error \(error)")
    }
    return rankList
  }
  
  func fetchPlayList() async -> Playlist? {
    struct Result: Decodable {
      let playlist: Playlist
      let privileges: [Track.Privilege]?
      let code: Int
    }
    let re:Result = load("wangyi/playlist");
    let playlist = re.playlist;
    
    // 每首歌请求详情
    guard let ids = re.playlist.trackIds?.map({ $0.id }) else {
      return nil
    }
    let list = stride(from: 0, to: ids.count, by: 500).map {
      Array(ids[$0..<($0+500 >= ids.count ? ids.count : $0+500)])
    }
    
    
    let rt:[[Track]] = await list.concurrentMap{ ids in
      let tracker = await self.songDetail(ids);
      return tracker
    }
    
    let tracks = rt.flatMap { $0 }
    var pl = playlist
    pl.tracks = tracks
    
    return pl
    
  }
  
  func songDetail(_ ids: [Int]) async -> [Track] {
    struct Result: Decodable {
      let songs: [Track]
      let code: Int
      let privileges: [Track.Privilege]
    }
    
    // 加载song.json的数据
    let res: Result = load("wangyi/song.json");
    
    let re = res.songs
    let p = res.privileges
    re.enumerated().forEach {
      guard $0.element.id == p[$0.offset].id else { return }
      re[$0.offset].privilege = p[$0.offset]
    }
    return re
    
  }
  
}
