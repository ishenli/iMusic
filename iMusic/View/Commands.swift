/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A set of menu commands.
 */

import SwiftUI
import Combine

struct Landmark: Hashable, Codable, Identifiable {
  var id: Int
  var name: String
  var park: String
  var state: String
  var description: String
  var isFavorite: Bool
  var isFeatured: Bool
  
  var category: Category
  enum Category: String, CaseIterable, Codable {
    case lakes = "Lakes"
    case rivers = "Rivers"
    case mountains = "Mountains"
  }
  
  private var imageName: String
  var image: Image {
    Image(imageName)
  }
  var featureImage: Image? {
    isFeatured ? Image(imageName + "_feature") : nil
  }
  
  private var coordinates: Coordinates
  
  struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
  }
}


struct LandmarkCommands: Commands {
  @FocusedBinding(\.selectedLandmark) var selectedLandmark
  @State private var filter = Preferences.shared.repeatMode
  

  var body: some Commands {
    SidebarCommands()
    CommandMenu("Controls") {
      Button("播放/暂停") {
        PlayCore.shared.togglePlayPause()
      }.keyboardShortcut(.space, modifiers: [.command])
      Button("下一首") {
        PlayCore.shared.nextSong()
      }.keyboardShortcut(.rightArrow, modifiers: [.command])
      Button("上一首") {
        PlayCore.shared.previousSong()
      }.keyboardShortcut(.leftArrow, modifiers: [.command])
      Divider()
      Picker(selection: $filter) {
        Text("不循环").tag(Preferences.RepeatMode.noRepeat)
        Text("单曲循环").tag(Preferences.RepeatMode.repeatItem)
        Text("列表循环").tag(Preferences.RepeatMode.repeatPlayList)
      } label: {
        Text("循环模式")
      }
      .onReceive(Just(filter)) {
        if(Preferences.shared.repeatMode != $0) {
          Preferences.shared.repeatMode = $0
          ControlBarViewModel.shared.initRepeatButton()
        }
      }
//      Divider()
//      Button("\(selectedLandmark?.isFavorite == true ? "Remove" : "Mark") as Favorite") {
//        selectedLandmark?.isFavorite.toggle()
//      }
//      .keyboardShortcut("f", modifiers: [.shift, .option])
//      .disabled(selectedLandmark == nil)
    }
  }
}

private struct SelectedLandmarkKey: FocusedValueKey {
  typealias Value = Binding<Landmark>
}

extension FocusedValues {
  var selectedLandmark: Binding<Landmark>? {
    get { self[SelectedLandmarkKey.self] }
    set { self[SelectedLandmarkKey.self] = newValue }
  }
}
