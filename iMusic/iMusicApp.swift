//
//  iMusicApp.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/21.
//

import SwiftUI

@main
struct iMusicApp: App {

  var body: some Scene {
    WindowGroup {
      HomeView()
        .background(Color.white)
        .frame(maxWidth: 970, maxHeight: 800)
    }
  }
}
