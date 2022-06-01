//
//  ControlBarViewModel.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/28.
//

import Foundation



enum ControlActionType {
  case previousButton
  case nextButton
  case pauseButton
  case playButton
}


class ControlBarViewModel: ObservableObject {
  @Published var isPlaying = false
  
  func controlAction(sender: ControlActionType) {
    let pc = PlayCore.shared
    let player = pc.player
    
    switch sender {
    case .pauseButton:
      print("pauseButto")
      isPlaying = true
    case .playButton:
      print("playButton")
      isPlaying = false
      pc.togglePlayPause()
    case .previousButton:
      print("previousButton")
      pc.previousSong()
    case .nextButton:
      print("nextButton")
      pc.nextSong()
    default:
      print("done")
    }
  }
}
