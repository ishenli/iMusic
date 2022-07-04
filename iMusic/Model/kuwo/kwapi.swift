//
//  netease.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/30.
//
import Foundation
import Cocoa
import Alamofire

class KWMusic : AbstractMusicPlatform {

  let nmSession: Session
  var reachabilityManager: NetworkReachabilityManager?
  
  init() {
    let session = Session(configuration: .default)
    session.sessionConfiguration.headers = HTTPHeaders.default
    nmSession = session
  }
  
  func apiRequest<T: Decodable>(
    _ url: String,
    _ params: [String: Any],
    _ m: HTTPMethod,
    _ resultType: T.Type) async throws -> T {
      
      do {

        let dataTask = nmSession.request(url, method: m, parameters: params).serializingData()
        let re = await dataTask.response
        
        guard var data = re.data else {
          Log.error(RequestError.noData)
          throw RequestError.noData
        }
        data = re.data!
        
        return try JSONDecoder().decode(resultType.self, from: data)
        
      } catch let error where error is ServerError {
        print(error)
        Log.error(error)
        throw RequestError.error(error)
      } catch let error {
        Log.error(error)
        throw RequestError.error(error)
      }
    }
  
  func fetchRecommend(page: Int) async -> [Rank] {
    let rankList: [Rank] = [];
    var p: [String: Any] = [
      "_": Date().milliStamp
    ]
    p["rn" ] = "25"
    p["pn"] = page
    p["order"] = "hot"
    p["httpsStatus"] = 1
  
    do {
      let res = try await self.apiRequest(
        "https://www.kuwo.cn/api/pc/classify/playlist/getRcmPlayList",
        p,
        .get,
        KWRecommendResource.self)
      
      return res.data.data.map { item in
        return Rank(name: item.name, imageUrl: item.img, id: Int(item.id)!, theme: -1)
      }
    } catch {
      print("Fetching fetchRecommend failed with error \(error)")
    }
    return rankList
  }
  
  func fetchPlayList(_ pid: Int) async -> Playlist? {
    let u = "https://www.kuwo.cn/api/www/playlist/playListInfo"
    
    var p: [String: Any] = [
      "_": Date().milliStamp
    ]
    p["pid"] = pid
    p["rn" ] = "100"
    p["pn"] = "1"
    
    do {
      let res = try await self.apiRequest(u, p, KWPlayListJSON.self);
      let data = res.data
      let tracks = data.musicList.map{ kw -> Track in
        let art = Artist(name: kw.artist, id: kw.artistid, picUrl: kw.albumpic)

        let Album = Album(name: kw.album, id: kw.albumid, picUrl: URL(string: kw.albumpic), publishTime: kw.releaseDate, artists: [art], size: 10)
        return Track(name: kw.name, id: kw.rid, platform: .kuwo, artists: [art], album:Album, duration: kw.duration * 1000, playable: true)
      }
      
      let c = Creator(nickname: data.uname, userId: -1, avatarUrl: URL(string: data.uPic))
      
      let tags = data.tag.components(separatedBy: ",")
      
      return Playlist(coverImgUrl: URL(string: data.img500)!, playCount: data.listencnt, name: data.name, trackCount: data.total, description: data.info, tags: tags , id: data.id, tracks: tracks, trackIds: [], creator: c, createTime: -1, createTimeStr: "")
      
    } catch {
      print("Fetching search failed with error \(error)")
      return nil
    }
  }
  
  
  func searchPlayList(keywords: String, page: Int) async -> PlatformSearchPlayListResult? {
    let u = "https://www.kuwo.cn/api/www/search/searchPlayListBykeyWord"
    
    var p: [String: Any] = [
      "_": Date().milliStamp
    ]
    p["key"] = keywords
    p["rn" ] = "20"
    p["pn"] = page
    
    do {
      let res = try await self.apiRequest(u, p, KWSearchPlayListJSON.self);
      let list = res.data.list.map { kw in
        return SearchPlayList(id: Int(kw.id)!, picUrl: URL(string: kw.img)!, playCount: Int(kw.listencnt)!, name: kw.name, Creator: Creator(nickname: kw.uname, userId: 0, avatarUrl: URL(string: AVATAR_DEFAULT)), trackCount: Int(kw.total)!, index: -1, platform: .kuwo)
      }
      
      return PlatformSearchPlayListResult(playList: list)
      
    } catch {
      print("Fetching search failed with error \(error)")
      return nil
    }
  }
  
  // 搜索
  func search(keywords: String, page: Int, type: SearchType) async -> PlatformSearchResult? {

    var p: [String: Any] = [
      "_": Date().milliStamp
    ]
    
    
    var u = ""
  
    switch type {
    case .songs:
      u = "https://www.kuwo.cn/api/www/search/searchMusicBykeyWord"
    case .albums:
      p["type"] = 10
    case .artists:
      p["type"] = 100
    case .playlists:
      p["type"] = 1000
      u = "https://www.kuwo.cn/api/www/search/searchPlayListBykeyWord"
    default:
      p["type"] = 0
    }
    
    p["key"] = keywords
    p["rn" ] = "20"
    p["pn"] = page
    
    do {
      let res = try await self.apiRequest(u,p, KWSearchResultJSON.self);
      return PlatformSearchResult(songs: res.data.list.map({ t in
        return t.toTrack()
      }))
    } catch {
      print("Fetching search failed with error \(error)")
      return nil
    }
  }


  
  func songUrl(_ ids: [Int]) async -> [Song] {
    var p: [String: Any] = [
      "type": "convert_url",
      "format": "mp3",
      "response":"url",
      "rid": ids[0]
    ]

    do {
      let dataTask = nmSession.request(
        "https://antiserver.kuwo.cn/anti.s",
        method: HTTPMethod.get,
        parameters: p).serializingString()
      
      let res = await dataTask.response
      let url = res.value ?? ""
      let s = Song(id: ids[0], url: URL(string: url)!, platform: .kuwo)
      return [s]
    } catch {
      print("Fetching songUrl failed with error \(error)")
    }
    return []
  }
  
  
  func getToken(isRetry: Bool) async -> String {
    let domain = "https://www.kuwo.cn";
    let name = "kw_token";
    
    var isRetryValue = true;
    if (isRetry == false) {
      isRetryValue = false;
    } else {
      isRetryValue = isRetry;
    }
    
    let cookie = GetCookieByUrlAndName(url: URL(string: domain)!, cookieName: name);
    
    if cookie == nil {
      if (isRetryValue) {
        return ""
      }
      // 请求http获取cooke
      let dataTask = nmSession.request("https://www.kuwo.cn/", method: .get, parameters: [:]).serializingData()
      _ = await dataTask.response
      
      return await self.getToken(isRetry: true)
    }

    return cookie ?? ""
  }
  
  func apiGetWithCookie(url: String, params: [String: Any]) async -> Data? {
    let token = await self.getToken(isRetry: false)
    let dataTask = nmSession.request(url, method: .get, parameters: params, headers: ["csrf": token,"Referer":"http://www.kuwo.cn/" ]).serializingData()
    let res = await dataTask.response
    
    if res.error != nil { // 重试
      let token2 = await self.getToken(isRetry: false)
      let dataTask2 = nmSession.request(url, method: .get, parameters: params, headers: ["csrf": token2, "Referer":"http://www.kuwo.cn/" ]).serializingData()
      let res2 = await dataTask2.response
      return res2.data
    }
    return res.data
  }
  
  func apiRequest<T: Decodable>(_ u:String, _ params: [String: Any], _ resultType: T.Type) async throws -> T {
    
    
    do {

      let data = await self.apiGetWithCookie(url: u, params: params)

      guard data != nil else {
        Log.error(RequestError.noData)
        throw RequestError.noData
      }
      
      return try JSONDecoder().decode(resultType.self, from: data!)
      
    } catch let error where error is ServerError {
      Log.error(error)
      throw RequestError.error(error)
    } catch let error {
      Log.error(error)
      throw RequestError.error(error)
    }
  }
  
  
  
  
}
