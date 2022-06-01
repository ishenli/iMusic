//
//  PlayListVM.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import Foundation


class PlayListViewModel: ObservableObject {
  
  @Published var isLoading = true
  @Published var tracks = [Track]()
  
  @MainActor
  func fetch() async {
    let data = await NetEaseMusic().fetchPlayList();
    
    isLoading = false;
    self.tracks = data?.tracks ?? [];
    debugPrint("isLoading", data)
  }
}
