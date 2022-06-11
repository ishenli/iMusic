//
//  PlayCore.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/28.
//

import Foundation
import AVFoundation
import MediaPlayer
import GSPlayer

enum PNItemType: Int {
  case withoutNext
  case withoutPrevious
  case withoutPreviousAndNext
  case other
}

@objc enum PlayerState: Int {
  case unknown = 0
  case playing = 1
  case paused = 2
  case stopped = 3
  case interrupted = 4
}

enum RepeatMode: Int {
  case noRepeat, repeatPlayList, repeatItem
}


enum ShuffleMode: Int {
  case noShuffle, shuffleItems, shuffleAlbums
}



class PlayCore: NSObject {
  static let shared = PlayCore();
  
  let api = NetEaseMusic()
  
  private let playerQueue = DispatchQueue(label: "com.xjbeta.NeteaseMusic.AVPlayerItem")
  
  // MARK: - NowPlayingInfoCenter
  
  let remoteCommandCenter = MPRemoteCommandCenter.shared()
  let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
  let seekTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
  
  
  
  var pnItemType: PNItemType = .withoutPreviousAndNext
  var fmMode = false
  @objc dynamic  var currentTrack: Track?
  var player: AVPlayer
  
  
  private var internalPlaylist = [Int]()
  
  // 根据 internalPlaylistIndex 来set pnItemType
  private var internalPlaylistIndex = -1 {
    didSet {
      switch (internalPlaylistIndex, fmMode) {
      case (0, false) where internalPlaylist.count == 1:
        pnItemType = .withoutPreviousAndNext
      case (0, _):
        pnItemType = .withoutPrevious
      case (-1, _):
        pnItemType = .withoutPreviousAndNext
      case (internalPlaylist.count - 1, false):
        pnItemType = .withoutNext
      case (playlist.count - 1, true):
        pnItemType = .withoutNext
      default:
        pnItemType = .other
      }
    }
  }
  
  @objc dynamic var playerState: PlayerState = .stopped {
    didSet {
      updateNowPlayingInfo()
      let state = MPNowPlayingPlaybackState(rawValue: UInt(playerState.rawValue)) ?? .stopped
      updateNowPlayingState(state)
    }
  }
  
  @objc dynamic var playProgress: Double = 0 {
      didSet {
          updateNowPlayingInfo()
      }
  }
  
  var periodicTimeObserverToken: Any?
  var timeControlStautsObserver: NSKeyValueObservation?
  
  
  var playerShouldNextObserver: NSObjectProtocol?
  var playerStateObserver: NSKeyValueObservation?
  
  
  @objc dynamic var playlist: [Track] = [] {
    didSet {
      guard fmMode else { return }
      if let ct = currentTrack,
         let i = playlist.firstIndex(of: ct) {
        internalPlaylistIndex = i
      } else {
        internalPlaylistIndex = -1
      }
    }
  }
  
  private var playingNextLimit = 20
  private var playingNextList: [Int] {
    get {
      
      let repeatMode = RepeatMode.noRepeat;
      updateInternalPlaylist()
      
      switch repeatMode {
      case .repeatItem where currentTrack != nil:
        return [currentTrack!.id]
      case .repeatItem where playlist.first != nil:
        return [playlist.first!.id]
      case .noRepeat, .repeatPlayList:
        let sIndex = internalPlaylistIndex + 1
        var eIndex = sIndex + playingNextLimit
        if eIndex > internalPlaylist.count {
          eIndex = internalPlaylist.count
        }
        return internalPlaylist[sIndex..<eIndex].map{ $0 }
      default:
        return []
      }
    }
  }
  
  // MARK: - AVPlayer Waiting
  
  private var itemWaitingToLoad: Int?
  private var loadingList = [Int]()
  var timeControlStatus: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
  
  override init() {
    player = AVPlayer()
    super.init()
    initPlayerObservers()
  }
  
  func initPlayerObservers() {
    timeControlStautsObserver = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] (player, changes) in
        self?.timeControlStatus = player.timeControlStatus
    }
    
    let timeScale = CMTimeScale(NSEC_PER_SEC)
    let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
    

    playerStateObserver = player.observe(\.rate, options: [.initial, .new]) { player, _ in
        guard player.status == .readyToPlay else { return }
        
        self.playerState = player.rate.isZero ? .paused : .playing
    }
    
    periodicTimeObserverToken = player .addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
        let pc = PlayCore.shared
        let player = pc.player
        
        self?.playProgress = player.playProgress
        
    }
    
    playerShouldNextObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
        self.nextSong()
    }
  }

  
  func togglePlayPause() {
    guard player.error == nil else { return }
    
    // 先初始化播放列表
    if PlayCore.shared.playlist.count == 0 {
      start([])
    } else {
      func playOrPause() {
        if player.rate == 0 {
          player.play()
        } else {
          player.pause()
        }
      }
      
      if currentTrack != nil {
          playOrPause()
      }
    }
  }
  
  
  func playNow(_ tracks: [Track]) {
      if let currentTrack = currentTrack,
          let i = playlist.enumerated().filter({ $0.element == currentTrack }).first?.offset {
          playlist.insert(contentsOf: tracks, at: i + 1)
      } else {
          playlist.append(contentsOf: tracks)
      }
      if let t = tracks.first {
          play(t)
      }
  }
  
  
  func previousSong() {
    let list = internalPlaylist;
    let id = list[internalPlaylistIndex - 1];
    guard let track = playlist.first(where: { $0.id == id }) else {
      return
    }
    internalPlaylistIndex -= 1
    play(track)
  }
  
  
  func nextSong() {
    
    let repeatMode = Preferences.shared.repeatMode
    // 重复播放
    guard repeatMode != .repeatItem else {
        player.seek(to: CMTime(value: 0, timescale: 1000))
        player.play()
        return
    }

    updateInternalPlaylist()
    let id = internalPlaylist[internalPlaylistIndex + 1]
    guard let track = playlist.first(where: { $0.id == id })
    else {
      print("Can't find next track.")
      stop()
      return
    }
    internalPlaylistIndex += 1
    play(track)
  }
  
  
  private func play(_ track: Track,
                    time: CMTime = CMTime(value: 0, timescale: 1000)) {
    
    currentTrack = track
    let song = track.song
    if ((song?.urlValid) != nil) {
      itemWaitingToLoad = nil
      realPlay(track)
    } else if itemWaitingToLoad == track.id {
      return
    } else {
      itemWaitingToLoad = track.id
      Task {
        await loadUrls(track)
      }
      
    }
  }
  
  
  //   url  Foundation.URL?  "http://m801.music.126.net/20220529041210/2758204e10958f3560c12bbb387529d1/jdymusic/obj/wo3DlMOGwrbDjj7DisKw/14096407901/1198/fd35/f521/616c2fa28b06073f8d0609e34e4bb3f8.mp3"
  private func realPlay(_ track: Track) {
    let song = track.song
    let baseUrl = song?.url
    
    guard ((song?.url) != nil) else {
      return;
    }
    
    playerQueue.async {
      let item = AVPlayerItem(url: baseUrl!)
      item.canUseNetworkResourcesForLiveStreamingWhilePaused = true
      
      DispatchQueue.main.async {
        self.player.replaceCurrentItem(with: item)
        self.player.play()
        self.playerState = .playing
      }
    }
  }
  
  private func loadUrls(_ track: Track) async {
    // 对歌词列表进行操作
    let list = playingNextList.filter {
      !loadingList.contains($0)
    }.compactMap { id in
      playlist.first(where: { $0.id == id })
    }.filter {
      $0.playable
    }.filter {
      !($0.song?.urlValid ?? false)
    }
    
    // 每次保留4首歌曲
    var ids = [track.id]
    if list.count >= 4 {
      let l = list[0..<4].map { $0.id }
      ids.append(contentsOf: l)
    } else {
      let l = list.map { $0.id }
      ids.append(contentsOf: l)
    }
    
    ids = Array(Set(ids))
    loadingList.append(contentsOf: ids)
    
    do {
      
      var preloadUrls = [URL]()
      
      
      let res = await api.songUrl(ids, 9990000);
      
      
      res.forEach { song in
        guard let track = self.playlist.first(where: { $0.id == song.id }) else { return }
        track.song = song
        self.loadingList.removeAll(where: { $0 == song.id })
        
        if self.itemWaitingToLoad == song.id {
          self.realPlay(track)
          self.itemWaitingToLoad = nil
        } else if song.url != nil {
          preloadUrls.append(song.url)
        }
      }
      //      let vpm = VideoPreloadManager.shared
      //      vpm.set(waiting: preloadUrls)
      
    } catch {
      Log.error("Load Song urls error: \(error)")
    }
  }
  
  
  func start(_ playlist: [Track],
             id: Int = -1,
             enterFMMode: Bool = false) {
    
    let pl = playlist.filter {
      $0.playable
    }
    guard pl.count > 0 else {
      return
    }
    
    var sid = id
    
    stop()
    
    self.playlist = pl
    
    initInternalPlaylist(sid)
    updateInternalPlaylist()
    
    // 指定某个歌曲
    if id != -1,
       let i = internalPlaylist.firstIndex(of: id),
       let track = playlist.first(where: { $0.id == id }) {
      internalPlaylistIndex = i
      play(track)
    } else if let id = internalPlaylist.first,
              let track = playlist.first(where: { $0.id == id }) {
      internalPlaylistIndex = 0
      play(track)
    } else {
      Log.error("Not find track to start play.")
    }
  }
  
  func stop() {
    
  }
  
  
  
  private func initInternalPlaylist(_ sid: Int) {
    let repeatMode = RepeatMode.noRepeat
    let shuffleMode = ShuffleMode.noShuffle
    internalPlaylist.removeAll()
    let idList = playlist.map {
      $0.id
    }
    var sid = sid
    guard idList.count > 0,
          let fid = idList.first,
          !fmMode else {
      internalPlaylistIndex = -1
      return
    }
    internalPlaylistIndex = 0
    
    if sid == -1 || !idList.contains(sid) {
      sid = fid
    }
    
    switch (repeatMode, shuffleMode) {
    case (.repeatItem, _):
      internalPlaylist = [sid]
    case (.noRepeat, .noShuffle),
      (.repeatPlayList, .noShuffle):
      var l = idList
      let i = l.firstIndex(of: sid)!
      l.removeSubrange(0..<i)
      internalPlaylist = l
    case (.noRepeat, .shuffleItems),
      (.repeatPlayList, .shuffleItems):
      var l = idList.shuffled()
      l.removeAll {
        $0 == sid
      }
      l.insert(sid, at: 0)
      internalPlaylist = l
    case (.noRepeat, .shuffleAlbums),
      (.repeatPlayList, .shuffleAlbums):
      var albumList = Set<Int>()
      var dic = [Int: [Int]]()
      playlist.forEach {
        let aid = $0.album.id
        var items = dic[aid] ?? []
        items.append($0.id)
        dic[aid] = items
        albumList.insert(aid)
      }
      let todo = ""
      break
    }
  }
  
  
  func updateInternalPlaylist() {
    guard !fmMode else { return }
    guard playlist.count > 0 else {
        Log.error("Nothing playable.")
        internalPlaylistIndex = -1
        currentTrack = nil
        return
    }
    
    let repeatMode = RepeatMode.repeatPlayList
    let shuffleMode = ShuffleMode.noShuffle
    
    let idList = playlist.map {
        $0.id
    }
    
    switch (repeatMode, shuffleMode) {
    case (.repeatPlayList, .noShuffle):
        while internalPlaylist.count - internalPlaylistIndex < playingNextLimit {
            internalPlaylist.append(contentsOf: idList)
        }
    case (.repeatPlayList, .shuffleItems):
        while internalPlaylist.count - internalPlaylistIndex < playingNextLimit {
            let list = idList + idList
            internalPlaylist.append(contentsOf: list.shuffled())
        }
    case (.repeatPlayList, .shuffleAlbums):
        break
    default:
        break
    }
  }
  
}
