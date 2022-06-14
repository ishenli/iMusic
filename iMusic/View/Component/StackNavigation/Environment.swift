import SwiftUI

typealias Push = (AnyView, Any?) -> ()


struct PushKey: EnvironmentKey {
  
  static let defaultValue: Push = { _, _ in }
  
}

struct CurrentViewKey: EnvironmentKey {
  
  static let defaultValue: AnyView? = nil
  
}

extension EnvironmentValues {
  
  var StackNavigationPush: Push {
    get { self[PushKey.self] }
    set { self[PushKey.self] = newValue }
  }

  var push: Push {
    get { self[PushKey.self] }
    set { self[PushKey.self] = newValue }
  }
  
  var currentView: AnyView? {
    get { self[CurrentViewKey.self] }
    set { self[CurrentViewKey.self] = newValue }
  }
  
}
