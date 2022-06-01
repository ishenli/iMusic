//
//  PlayListView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import SwiftUI

struct Person: Identifiable {
  let givenName: String
  let familyName: String
  let id = UUID()
}

struct PlayListView: View {
  
  private var people = [
    Person(givenName: "Juan", familyName: "Chavez"),
    Person(givenName: "Mei", familyName: "Chen"),
    Person(givenName: "Tom", familyName: "Clark"),
    Person(givenName: "Gita", familyName: "Kumar"),
  ]

  var body: some View {
    Table(people) {
      TableColumn("音乐标题", value: \.givenName)
      TableColumn("歌手", value: \.givenName)
      TableColumn("时长", value: \.familyName)
    }
  }
}

struct PlayListView_Previews: PreviewProvider {
  static var previews: some View {
    PlayListView()
  }
}
