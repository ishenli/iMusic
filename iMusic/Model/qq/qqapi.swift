//
//  netease.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/30.
//
import Foundation
import Cocoa
import Alamofire

class QQMusic : AbstractMusicPlatform {
  
  
  
  
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
        
        let dataTask = nmSession.request(url, method: m, parameters: params, headers: ["Referer": "http://y.qq.com/"]).serializingData()
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
  
  func fetchRecommend() async -> [Rank] {
    let rankList: [Rank] = [];
    do {
      let data = try await self.apiRequest(
        "https://music.163.com/eapi/v1/discovery/recommend/resource",
        [:],
        .post,
        RecommendResource.self)
      
      return data.recommend.map {
        Rank.init(name: $0.name, imageUrl: $0.picUrl.absoluteString, id: $0.id, theme: 0)
      }
    } catch {
      print("Fetching fetchRecommend failed with error \(error)")
    }
    return rankList
  }
  
  func fetchPlayList(_ id: Int) async -> Playlist? {
    return nil
  }
  
  
  func searchPlayList(keywords: String, page: Int) async -> PlatformSearchPlayListResult? {
    return nil
  }
  
  // 搜索
  func search(keywords: String, page: Int, type: SearchType) async -> PlatformSearchResult? {
    
    var p: [String: Any] = [
      "total": true
    ]
    
    
    var u = ""
    
    // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
    switch type {
    case .songs:
      p["type"] = 1
      p["g_tk" ] = "938407465"
      p["uin" ] = "0"
      p["format" ] = "json"
      p["inCharset" ] = "utf-8"
      p["outCharset" ] = "utf-8"
      p["notice" ] = "0"
      p["platform" ] = "h5"
      p["needNewCode" ] = "1"
      p["w" ] = keywords
      p["zhidaqu" ] = "1"
      p["catZhida" ] = "1"
      p["t" ] = "0"
      p["flag" ] = "1"
      p["ie" ] = "utf-8"
      p["sem" ] = "1"
      p["aggr" ] =  "0"
      p["perpage" ] = "20"
      p["n" ] = "20"
      p["p" ] = page
      p["remoteplace" ] = "txt.mqq.all"
      p["_" ] = Date().milliStamp
      u = "https://c.y.qq.com/soso/fcgi-bin/client_search_cp";
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
      let res = try await self.apiRequest(u,p, HTTPMethod.get, QQSearchResultJSON.self);
      return PlatformSearchResult(songs: res.data.song.list.map({ QQTrack in
        return QQTrack.toTrack()
      }))
    } catch {
      Log.error("Fetching search failed with error \(error)")
      return nil
    }
  }
  
  
  func fetchRecommend(page: Int) async -> [Rank] {
    return []
  }
  
  
  //  func songUrl() -> [Song] {
  //    struct Result: Decodable {
  //      let data: [Song]
  //      let code: Int
  //    }
  //
  //    do {
  //      let res = try await self.eapiRequest(
  //        "https://music.163.com/eapi/song/enhance/player/url",
  //        p,
  //        Result.self,
  //        shouldDeSerial: true)
  //
  //      return res.data
  //    } catch {
  //      print("Fetching songUrl failed with error \(error)")
  //    }
  
  //  }
  
  func songUrl(_ ids: [Int]) async -> [Song] {
    return []
  }
  
  func fetchCategoryFilter() async -> [CategoryFilter] {
    var p: [String: Any] = [
      "picmid": "1",
      "rnd": "\(randomInt(8))",
      "g_tk":"732560869",
      "loginUin":"0",
      "hostUin":"0",
      "notice":"0",
      "format":"json",
      "inCharset":"utf8",
      "outCharset":"utf-8",
      "platform":"yqq.json",
      "needNewCode": "0"
    ]
    var all: [CategoryFilter] = []
    do {
      let res = try await self.apiRequest("https://c.y.qq.com/splcloud/fcgi-bin/fcg_get_diss_tag_conf.fcg", p, HTTPMethod.get, QQCategoryFilter.self);
      res.data.categories.forEach { CategoryGrooupItem in
        var c = CategoryFilter(categoryGroupName: CategoryGrooupItem.categoryGroupName, filters: [])
        if CategoryGrooupItem.usable == 1 {
          CategoryGrooupItem.items.forEach { CategoryFilterItem in
            c.filters.append(CategoryFilter.filterItem(id: CategoryFilterItem.categoryId, name: CategoryFilterItem.categoryName))
          }
          all.append(c)
        }
      }
      return all
    } catch {
      Log.error("Fetching fetchCategoryFilter failed with error \(error)")
    }
    return []
  }
  
  
  private func randomInt(_ digits: Int) -> Int {
    let min = Int(pow(10, Double(digits-1))) - 1
    let max = Int(pow(10, Double(digits))) - 1
    return Int.random(in: (min...max))
  }
}
