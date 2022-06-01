//
//  kugou.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/23.
//

import Foundation
import Alamofire

let KuGouRecommendRequestConfig = [
  "url": "http://mobilecdnbj.kugou.com/api/v3/tag/recommend?showtype=3&apiver=2&plat=0",
  "parameters": "",
  "headers": [
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36",
    "origin": "https://music.163.com"
  ]
] as [String : Any]


struct KugouRankItem : Hashable, Codable {
  let jump_url, icon, name, bannerurl: String
  let id, is_new, has_child, theme: Int
}

struct RecommendResponse: Codable {
  var status: Int
  var data: RecommendData
}

struct RecommendData: Codable {
  let info: [KugouRankItem]
}

class Kugou {
  func fetchRecommand() async -> [Rank] {
    let dataTask = AF.request("http://mobilecdnbj.kugou.com/api/v3/tag/recommend?showtype=3&apiver=2&plat=0",
                              method: .post,
                              parameters: "",
                              encoder: JSONParameterEncoder.default)
    var rankList: [Rank] = [];
    do {
      let res = try await dataTask.serializingDecodable(RecommendResponse.self).value
  
      res.data.info.forEach({ KugouRankItem in
        
        if !KugouRankItem.bannerurl.isEmpty {
          rankList.append(Rank.init(
            name: KugouRankItem.name,
            imageUrl: KugouRankItem.bannerurl.replacingOccurrences(of: "/{size}", with: ""), // 去掉特殊字符串
            id: KugouRankItem.id,
            theme: KugouRankItem.theme)
          )
        }
        
      })
      
      return rankList
        
    } catch {
      print("Fetching images failed with error \(error)")
    }
    print("starting done")
    return rankList
  }
}


//jump_url: "",
//icon: "",
//id: 1561,
//is_new: 0,
//has_child: 0,
//imgurl: "",
//special_tag_id: 1150,
//song_tag_id: 0,
//theme: 1,
//bannerurl: "",
//name: "国语经典",
//album_tag_id: 0

