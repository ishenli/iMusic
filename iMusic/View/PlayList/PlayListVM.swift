//
//  PlayListVM.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import Foundation


class PlayListViewModel: ObservableObject {
  
  static let Shared = PlayListViewModel()
  
  @Published var playList: Playlist?
  
  @Published var isLoading = true
  @Published var tracks = [Track]()
  
  var currentTrackObserver: NSKeyValueObservation?
  var playerStateObserver: NSKeyValueObservation?
  
  init() {
    initObservers()
  }
  
  func initObservers() {
    currentTrackObserver?.invalidate()
    playerStateObserver?.invalidate()
    
    // 监听当前播放的歌曲，用来高亮
    currentTrackObserver = PlayCore.shared.observe(\.currentTrack, options: [.new, .initial]) { (pc, _) in
        self.initCurrentTrack()
    }
    
    playerStateObserver =  PlayCore.shared.observe(\.timeControlStatus, options: [.new, .initial]) { (pc, _) in
        let pc = PlayCore.shared
        self.tracks.first {
            $0.isCurrentTrack
            }?.isPlaying = pc.player.timeControlStatus == .playing
    }
  }
  
  func initCurrentTrack() {
      let pc = PlayCore.shared
      tracks.filter {
          $0.isCurrentTrack
      }.forEach {
          $0.isCurrentTrack = false
      }
      
      guard let c = pc.currentTrack else { return }

      let t = tracks.first {$0.id == c.id}
      t?.isCurrentTrack = true
      t?.isPlaying = pc.player.timeControlStatus == .playing
  }
  
  
  @MainActor
  func fetch(id: Int) async -> Void {
          
    self.isLoading = true
    
    var data = await NetEaseMusic().fetchPlayList(id);

    if ((data?.createTime) != nil) {
      let df = DateFormatter()
      df.dateFormat = "yyyy-MM-dd"
      let interval:TimeInterval = TimeInterval.init(Double(data!.createTime) / 1000) // 是毫秒
      let date = Date(timeIntervalSince1970: interval)
      data?.createTimeStr = df.string(from: date)
    }
    
    self.tracks = data?.tracks.initIndexes() ?? []
    self.playList = data
    self.isLoading = false;
  }
  
  func playAll() -> Void {
    self.startPlay(true)
  }
  
  func startPlay(_ all: Bool) {
    let tracks = all ? tracks:  [];
    PlayCore.shared.start(tracks)
  }
  
  func playOneSong(_ track: Track) -> Void {
    
  }
}
