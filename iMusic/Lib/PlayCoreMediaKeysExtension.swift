//
//  PlayCoreMediaKeysExtension.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/8.
//

import Foundation
import MediaPlayer
import SDWebImage


extension PlayCore {
  
  func updateNowPlayingState(_ state: MPNowPlayingPlaybackState) {
      nowPlayingInfoCenter.playbackState = state
  }

  func initNowPlayingInfo() {
      guard let track = currentTrack,
            let appIcon = NSApp.applicationIconImage else {
          nowPlayingInfoCenter.nowPlayingInfo = nil
          updateNowPlayingState(.unknown)
          return
      }
      
      var info = [String: Any]()
      
      info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
      info[MPMediaItemPropertyTitle] = track.name
      info[MPMediaItemPropertyArtist] = track.artistsString
      
      info[MPMediaItemPropertyAlbumArtist] = track.album.artists?.artistsString
      info[MPMediaItemPropertyAlbumTitle] = track.album.name
      
      info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: .init(width: 512, height: 512)) {
          
          guard let u = track.album.picUrl?.absoluteString.appending("?param=\(Int($0.width))y\(Int($0.height))"),
                let url = URL(string: u),
                let key = ImageLoader.key(url) else {
              return appIcon
          }
          
          if let image = SDImageCache.shared.imageFromMemoryCache(forKey: key) {
              return image
          } else if let image = NSImage(contentsOf: url) {
              SDImageCache.shared.store(image, forKey: key, completion: nil)
              return image
          } else {
              return appIcon
          }
      }
      nowPlayingInfoCenter.nowPlayingInfo = nil
      nowPlayingInfoCenter.nowPlayingInfo = info
  }
  
  func updateNowPlayingInfo() {
      guard let track = currentTrack,
            nowPlayingInfoCenter.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String == track.name else {
          return
      }
      
      var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
      info[MPMediaItemPropertyPlaybackDuration] = track.duration / 1000
      info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentDuration
      
      info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
      info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1
      nowPlayingInfoCenter.nowPlayingInfo = info
  }
}
