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
  
  
  @MainActor
  func fetch(id: Int) async -> Void {
          
    self.isLoading = true
    
    var data = await NetEaseMusic().fetchPlayList(id);

    
    if ((data?.createTime) != nil) {
      let df = DateFormatter()
      df.dateFormat = "yyyy-MM-dd"
      //      let date = df.date(from: String(1490837055281))
      print(data!.createTime)
      let interval:TimeInterval = TimeInterval.init(Double(data!.createTime))
      print(interval)
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
