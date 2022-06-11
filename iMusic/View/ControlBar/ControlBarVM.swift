//
//  ControlBarViewModel.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/28.
//

import Foundation
import Cocoa
import AVFoundation
import SwiftUI


enum ControlActionType {
  case previousButton
  case nextButton
  case pauseButton
  case playButton
  case muteButton
}



struct ControllerBarTextField {
  var isHidden: Bool
  var text: String
}

struct PlayerSlider {
  var maxValue: Double
  var doubleValue: Double
  var cachedDoubleValue: Double
}

struct VolumeSlider {
  var maxValue: Float
  var floatValue: Float
}

struct MuteButton {
  var isMuted: Bool;
  var image: String
  var contentTintColor: Color
}

class ControlBarViewModel: ObservableObject {
  
  static let shared = ControlBarViewModel()
  
  @objc dynamic var currentTrack: Track?
  
  @Published var isPlaying = false
  @Published var trackNameTextField: ControllerBarTextField = ControllerBarTextField(isHidden: true, text: "")
  @Published var trackSecondNameTextField: ControllerBarTextField = ControllerBarTextField(isHidden: true, text: "")
  @Published var trackPicButton: String = ""
  
  
  @Published var durationSlider: PlayerSlider! = PlayerSlider(maxValue: 0, doubleValue: 0, cachedDoubleValue: 0)
  @Published var durationTextField: ControllerBarTextField = ControllerBarTextField(isHidden: true, text: "")
  @Published var volumeSlider: VolumeSlider! = VolumeSlider(maxValue: 0, floatValue: 0)
  
  
  @Published var muteButton: MuteButton = MuteButton(isMuted: false, image: "speaker", contentTintColor: Color.black)
  
  var playProgressObserver: NSKeyValueObservation?
  var pauseStautsObserver: NSKeyValueObservation?
  var previousButtonObserver: NSKeyValueObservation?
  var currentTrackObserver: NSKeyValueObservation?
  var fmModeObserver: NSKeyValueObservation?
  var volumeChangedNotification: NSObjectProtocol?
  
  init() {
    let pc = PlayCore.shared
    

    playProgressObserver = pc.observe(\.playProgress, options: [.initial, .new]) { [weak self] pc, _ in
      
      guard self?.durationSlider != nil, self?.durationTextField != nil else {
        return;
      }

      let player = pc.player
      guard player.currentItem != nil else {
        self?.durationSlider.maxValue = 0
        self?.durationSlider.doubleValue = 0
        self?.durationSlider.cachedDoubleValue = 0
        self?.durationTextField.text = "00:00 / 00:00"
        return
      }
      
      let cd = player.currentDuration
      let td = player.totalDuration
      
      if td != self?.durationSlider.maxValue {
        self?.durationSlider.maxValue = td
      }
      self?.durationSlider.doubleValue = cd
      self?.durationSlider.cachedDoubleValue = player.currentBufferDuration
      
      self?.durationTextField.text = "\(cd.durationFormatter()) / \(td.durationFormatter())"
    }
    
    
    currentTrackObserver = pc.observe(\.currentTrack, options: [.initial, .new]) { [weak self] pc, _ in
      self?.initViews(pc.currentTrack)
    }
    
    pauseStautsObserver = pc.observe(\.playerState, options: [.initial, .new]) { [weak self] pc, _ in
      self?.isPlaying = pc.playerState == .playing
      
    }
    
    // 各种初始化
    
    // 音量按钮
    initVolumeButton()
  }
  
  func initViews(_ track: Track?) {
    
    if track != nil  {
      let t = track!
      trackPicButton = t.album.picUrl?.absoluteString ?? ""
      trackNameTextField.isHidden = t.name == ""
      trackNameTextField.text = t.name
      let name = t.artists[0].name
      trackSecondNameTextField.isHidden = name == ""
      trackSecondNameTextField.text = name
      durationTextField.isHidden = false
    } else {
      trackPicButton = ""
      trackNameTextField.text = ""
      trackSecondNameTextField.text = ""
      durationTextField.isHidden = true
    }
    
    durationSlider.maxValue = 1
    durationSlider.doubleValue = 0
    durationSlider.cachedDoubleValue = 0
    durationTextField.text = "00:00 / 00:00"
  }
  
  func changePlaySlider(_ began: Bool) {
    if !began {
      let time = CMTime(seconds: self.durationSlider.doubleValue, preferredTimescale: 1000)
      PlayCore.shared.player.seek(to: time) { _ in }
    }
  }
  
  func changeVolume(_ began: Bool) {
    if !began {
      let v = volumeSlider.floatValue
      PlayCore.shared.player.volume = Float(v)
      Preferences.shared.volume = v
      initVolumeButton()
    }
  }
  
  func controlAction(sender: ControlActionType) {
    let pc = PlayCore.shared
    let player = pc.player
    let preferences = Preferences.shared
    
    switch sender {
    case .pauseButton:
      print("pauseButto")
      pc.togglePlayPause()
    case .playButton:
      print("playButton")
      pc.togglePlayPause()
    case .previousButton:
      print("previousButton")
      pc.previousSong()
    case .nextButton:
      print("nextButton")
      pc.nextSong()
    case .muteButton:
        let mute = !player.isMuted
        player.isMuted = mute
        preferences.mute = mute
        initVolumeButton()
    default:
      print("done")
    }
  }
  
  func showPlayListPanel() {
    
  }
  
  
  func initVolumeButton() {
    let pc = PlayCore.shared
    let pref = Preferences.shared
    
    let volume = pref.volume
    volumeSlider.floatValue = volume
    pc.player.volume = volume
    
    let mute = pref.mute
    pc.player.isMuted = mute
    
    print("volumie:\(volume)")
    
    var imageName = ""
    var color = Color.black
    if mute {
        imageName = "speaker.slash"
        color = .gray
    } else {
        switch volume {
        case 0:
            imageName = "speaker"
            color = .gray
        case 0..<1/3:
            imageName = "speaker.wave.1"
        case 1/3..<2/3:
            imageName = "speaker.wave.2"
        case 2/3...1:
            imageName = "speaker.wave.3"
        default:
            imageName = "speaker"
        }
    }
    imageName += ".Regular-M"
    muteButton.image = imageName
    muteButton.contentTintColor = color
  }
}
