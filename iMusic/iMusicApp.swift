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
        .background(Color.yellow)
        .frame(maxWidth: 1200, maxHeight: 800)
        .onAppear {
          NSApplication.shared.windows.forEach({ $0.tabbingMode = .disallowed })
        }
    }
    .commands {
      CommandGroup(replacing: .newItem, addition: { })
      LandmarkCommands()
    }
    
    Settings {
      LandmarkSettings()
    }
  }
}
