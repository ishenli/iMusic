//
//  SearchVM.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/13.
//

import Foundation


struct SearchTypeTabItems: Hashable, Identifiable {
  let tabName: String
  let id: Int
  let searchType: SearchType
}


class SearchViewModel: ObservableObject {
  static let Shared: SearchViewModel = SearchViewModel()
  
  public var keyword: String = ""
  public var page: Int = 0

  @Published var searchType: SearchType = SearchType.songs
  @Published var isLoading = true
  @Published var searchSongList = [Track]()
  @Published var searchPlayList = [SearchPlayList]()
  
  @Published var platformSelected: Int = MusicPlatformList[0].id
  
  var platformTabs:[TabItems] = MusicPlatformList.map { MusicPlatformMeta in
    return TabItems.init(tabName: MusicPlatformMeta.title, tag: MusicPlatformMeta.name, id: MusicPlatformMeta.id)
  }
  
  
  var searchTypeTabs: [SearchTypeTabItems] = [
    SearchTypeTabItems(tabName: "单曲", id: SearchType.songs.rawValue, searchType: SearchType.songs),
    SearchTypeTabItems(tabName: "歌单", id: SearchType.playlists.rawValue, searchType: SearchType.playlists)
  ]
  
  
  var currentTrackObserver: NSKeyValueObservation?
  var playerStateObserver: NSKeyValueObservation?
  
  init() {
    initObservers()
    initCurrent()
  }
  
  func initObservers() {
    
    currentTrackObserver = PlayCore.shared.observe(\.currentTrack, options: [.new, .initial]) { (pc, _) in
      self.initCurrent()
    }
  }
  
  
  func initCurrent() {
    self.searchSongList.filter {
      $0.isCurrentTrack
    }.forEach {
      $0.isCurrentTrack = false
    }
    
    guard let c = PlayCore.shared.currentTrack else { return }
    self.searchSongList.first {
      $0.id == c.id
    }?.isCurrentTrack = true
  }
  
  
  
  func fetchWithPage(page: Int) {
    Task {
      await self.searchByKeyword(page: page)
    }
  }
  
  
  func fetch(keyword: String, type: SearchType = .songs, page: Int = 0) async {
    guard keyword != "" else {
      return
    }
    
    // 所有属性放在实例上
    self.keyword = keyword
    self.searchType = type
    self.page = page
    
    await searchByKeyword(page: page)
    
  }
  
  func platformTabClick(id: Int) -> Void {
    self.platformSelected = id
    self.page = 0
    Task {
      await self.searchByKeyword(page: self.page)
    }
  }
  
  func searchTypeTabClick(type: SearchType) -> Void {
    self.searchType = type
    self.page = 0
    Task {
      await self.searchByKeyword(page: self.page)
    }
  }
  
  
  func searchByKeyword(page: Int) async {
    self.isLoading = true
    switch searchType {
    case .songs:
      await self.searchSongsByKeyword(page: page)
    case .none:
      print("none")
    case .albums:
      print("albums")
    case .artists:
      print("artists")
    case .playlists:
      await self.searchPlayListByKeyword(page: page)
    }
  }
  
  func searchPlayListByKeyword(page: Int) async {
    let PlatformIns = getPlatformInstance(id: self.platformSelected)
    let data = await PlatformIns.searchPlayList(keywords: self.keyword, page: page);
    isLoading = false
    if data?.playList != nil {
      data?.playList.initIndexes()
      self.searchPlayList = data?.playList ?? []
    }
  }
  
  
  func searchSongsByKeyword(page: Int) async {
    let data = await MusicPlatform.Shared.search(keyword: self.keyword, id: self.platformSelected, page: page, searchType: self.searchType)
    isLoading = false
    if data?.songs != nil {
      data!.songs.initIndexes()
      self.searchSongList = data?.songs ?? []
      initCurrent()
    }
  }
}
