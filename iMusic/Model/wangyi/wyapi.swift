//
//  NeteaseMusicAPI.swift
//  NeteaseMusic
//
//  Created by xjbeta on 2019/3/31.
//  Copyright © 2019 xjbeta. All rights reserved.
//

import Cocoa
import Alamofire
import PromiseKit

class NeteaseMusicAPI {
  
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
  
  
  var uid = -1
  var csrf: String {
    get {
      return HTTPCookieStorage.shared.cookies?.filter({ $0.name == "__csrf" }).first?.value ?? ""
    }
  }
  
  struct CodeResult: Decodable {
    let code: Int
    let msg: String?
  }
  
  func startNRMListening() {
    stopNRMListening()
    
    reachabilityManager = NetworkReachabilityManager(host: "music.163.com")
    reachabilityManager?.startListening { status in
      switch status {
      case .reachable(.cellular):
        Log.error("NetworkReachability reachable cellular.")
      case .reachable(.ethernetOrWiFi):
        Log.error("NetworkReachability reachable ethernetOrWiFi.")
      case .notReachable:
        Log.error("NetworkReachability notReachable.")
      case .unknown:
        break
      }
    }
  }
  
  func stopNRMListening() {
    reachabilityManager?.stopListening()
    reachabilityManager = nil
  }
  
  func nuserAccount() -> Promise<NUserProfile?> {
    struct Result: Decodable {
      let code: Int
      let profile: NUserProfile?
    }
    
    return eapiRequest(
      "https://music.163.com/eapi/nuser/account/get",
      [:],
      Result.self).map {
        $0.profile
      }
  }
  
  func userPlaylist() -> Promise<[Playlist]> {
    struct Result: Decodable {
      let playlist: [Playlist]
      let code: Int
    }
    
    let p = [
      "uid": uid,
      "offset": 0,
      "limit": 1000
    ]
    
    return eapiRequest("https://music.163.com/eapi/user/playlist/",
                       p,
                       Result.self).map {
      $0.playlist
    }
  }
  
  
  func songUrl(_ ids: [Int], _ br: Int) -> Promise<([Song])> {
    struct Result: Decodable {
      let data: [Song]
      let code: Int
    }
    
    let p: [String : Any] = [
      "ids": ids,
      "br": br,
      "e_r": true
    ]
    
    let r: Result = load("wangyi/player")
  
    return Promise { resolver in
      resolver.fulfill(r.data)
    }
    
//    return eapiRequest("https://music.163.com/eapi/song/enhance/player/url",
//                       p,
//                       Result.self,
//                       shouldDeSerial: true).map {
//      $0.data
//    }
  }
  
  func recommendResource() -> Promise<[RecommendResource.Playlist]> {
    eapiRequest(
      "https://music.163.com/eapi/v1/discovery/recommend/resource",
      [:],
      RecommendResource.self).map {
        $0.recommend
      }
  }
  
  func recommendSongs() -> Promise<[Track]> {
    eapiRequest(
      "https://music.163.com/eapi/v1/discovery/recommend/songs",
      [:],
      RecommendSongs.self).map {
        $0.recommend
      }.map {
//        $0.forEach {
//          $0.from = (.discoverPlaylist, -114514, "recommend songs")
//        }
        return $0
      }
  }
  
  func lyric(_ id: Int) -> Promise<(LyricResult)> {
    let u = "https://music.163.com/api/song/lyric?os=osx&id=\(id)&lv=-1&kv=-1&tv=-1"
    
    return Promise { resolver in
      AF.request(u).responseDecodable(of: LyricResult.self) {
        do {
          resolver.fulfill(try $0.result.get())
        } catch let error {
          resolver.reject(error)
        }
      }
    }
  }
  
  
  func eapiRequest<T: Decodable>(
    _ url: String,
    _ params: [String: Any],
    _ resultType: T.Type,
    shouldDeSerial: Bool = false,
    debug: Bool = false) -> Promise<T> {
      
      
      
      return Promise { resolver in
        let p = try channel.serialData(params, url: url)
        
        nmSession.request(url, method: .post, parameters: ["params": p]).response { re in
          
          if debug, let d = re.data,
             let str = String(data: d, encoding: .utf8) {
            Log.verbose(str)
          }
          
          if let error = re.error {
            resolver.reject(RequestError.error(error))
            return
          }
          guard var data = re.data else {
            resolver.reject(RequestError.noData)
            return
          }
          
          do {
            if shouldDeSerial {
              if let d = try self.channel.deSerialData(data.toHexString(), split: false)?.data(using: .utf8) {
                data = d
              } else {
                throw RequestError.noData
              }
            }
            
            if let re = try? JSONDecoder().decode(ServerError.self, from: data),
               re.code != 200 {
              throw re
            }
            
            let re = try JSONDecoder().decode(resultType.self, from: data)
            
            resolver.fulfill(re)
          } catch let error where error is ServerError {
            guard let err = error as? ServerError else { return }
            
            var msg = err.msg ?? err.message ?? ""
            
            if err.code == -462 {
              msg = "绑定手机号或短信验证成功后，可进行下一步操作哦~🙃"
            }
            
            let u = re.request?.url?.absoluteString ?? ""
            resolver.reject(RequestError.errorCode((err.code, "\(u)  \(msg)")))
          } catch let error {
            resolver.reject(error)
          }
        }
      }
    }
  
  enum RequestError: Error {
    case error(Error)
    case noData
    case errorCode((Int, String))
    case unknown
  }
  
  
  enum APIError: Error {
    case errorCode(Int)
  }
  
}

extension Encodable {
  func jsonString() -> String {
    guard let data = try? JSONEncoder().encode(self),
          let str = String(data: data, encoding: .utf8) else {
      return ""
    }
    return str
  }
}
