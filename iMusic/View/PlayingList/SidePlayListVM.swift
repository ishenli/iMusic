//
//  SidePlayListVM.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/11.
//

import Foundation


class SidePlayListViewModel: ObservableObject {
  
  static var Shared = SidePlayListViewModel();
  
  @Published var playlist = [Track]()
  @Published var isVisible = false;
  
  var playlistObserver: NSKeyValueObservation?
  var historysObserver: NSKeyValueObservation?
  
  var currentTrackObserver: NSKeyValueObservation?
  var playerStateObserver: NSKeyValueObservation?
  
  init() {
    initObservers()
  }
  
  func initObservers() {
    playlistObserver?.invalidate()
    historysObserver?.invalidate()
    
    // Playlist
    playlistObserver = PlayCore.shared.observe(\.playlist, options: [.initial, .new]) { [weak self] core, _ in
      self?.playlist = core.playlist
    }
    
    currentTrackObserver = PlayCore.shared.observe(\.currentTrack, options: [.new, .initial]) { (pc, _) in
      
      self.playlist.filter {
        $0.isCurrentTrack
      }.forEach {
        $0.isCurrentTrack = false
      }
      
      guard let c = pc.currentTrack else { return }
      self.playlist.first {
        $0.id == c.id
      }?.isCurrentTrack = true
    }
  }
  
  func empty() {
    PlayCore.shared.playlist.removeAll()
  }
  
  
  func playOneSong(_ track: Track) -> Void {
    PlayCore.shared.start([track], id: track.id)
  }
}
