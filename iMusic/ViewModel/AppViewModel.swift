//
//  AppViewModel.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/26.
//

import Foundation


class AppViewModel: ObservableObject {
  
  static let Shared: AppViewModel = AppViewModel()
  
  @Published var globalToastShow: Bool = false
  @Published var globalToastText: String = ""
  
  var messageObserver: NSKeyValueObservation?
  
  
  init() {
    initObservers()
  }
  
  func initObservers() {

    let pc = PlayCore.shared

    messageObserver = pc.observe(\.toastMessage, options: [.new]) { [weak self] pc, _ in
      if pc.toastMessage != nil {
//        self?.showToast(content: pc.toastMessage!)
        print("toastMessage\(pc.toastMessage)")
        self?.showToast(content: pc.toastMessage ?? "ಥ_ಥ，有点小错误 ~~")
      }
    }
  }
  
  func showToast(content: String) {
    globalToastText = content
    globalToastShow = true
  }
}
