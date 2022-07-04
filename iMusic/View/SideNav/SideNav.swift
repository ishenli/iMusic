//
//  SideNav.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/27.
//

import SwiftUI
import Introspect

struct CategoryItem: Hashable {
  let key: CategoryKey
  let title: String
  let image: String
}

struct WorkItem : Hashable {
  let key: String
  let title: String
  let categoryList: [CategoryItem]
}


enum CategoryKey {
  case MySong
  case Rank
  case MySinger
  case Setting
  case PlaySetting
  case PersonInfo
}


struct SideNav: View {
  let works:[WorkItem] = [
    .init(key: "Music", title: "我的音乐", categoryList: [
      .init(key: .Rank, title: "发现音乐", image: "align.vertical.bottom.fill"),
      .init(key: .MySong, title: "我的歌单", image: "music.note"),
      .init(key: .MySinger, title: "歌星", image: "person.fill"),
      .init(key: .PlaySetting, title: "播放器设置", image: "gear.circle"),
      .init(key: .PersonInfo, title: "个人信息", image: "info.circle"),
    ]),
//    .init(key: "Setting", title: "我的音乐", categoryList: [
//
//    ])
  ]
  
  @Binding var selection: CategoryKey?;
  
  var body: some View {
    VStack {
      Spacer()
        .frame(height: 14)
      SearchInputView()
      VStack(
        alignment: .leading
      ) {
        ForEach((works), id: \.self) { option in
          CategoryView (
            workItem: option,
            selection: $selection
          )
        }
      }
      .frame(alignment: .topLeading)
      .padding(.top, 10)
      Spacer()
    }.frame(width: 220)
  }
}

struct NavigationLinkStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(Color.primary)
  }
}

struct CategoryView : View {
  var workItem: WorkItem
  
  @Binding var selection: CategoryKey?;
  
  var body: some View {
    
      List {
        ForEach(Array(workItem.categoryList.enumerated()), id: \.offset) { index, option in
          SidebarNavigationLink(destination: MainView(currentOption: option.key), tag: option.key, selection: $selection){
            HStack {
              Image(systemName: option.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:14, height: 14)
//                .foregroundColor(option.key == selection ? Color.white: Color.primary)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              Text(option.title)
              Spacer()
            }
//            .foregroundColor(option.key == selection ? Color.white: Color.black)
            .frame(width:180, height: 30)
          }
        }
      }.listStyle(SidebarListStyle())
  }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
  @State var value: Value
  var content: (Binding<Value>) -> Content
  
  var body: some View {
    content($value)
  }
  
  init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
    self._value = State(wrappedValue: value)
    self.content = content
  }
}


struct SideNav_Previews: PreviewProvider {
  static var previews: some View {
    //    StatefulPreviewWrapper(CategoryKey.Rank) {
    //      SideNav(
    //        currentSelection: $0,
    //        selection: $selection
    //      )
    //    }
    
    Group {
      SideNav(
        selection: .constant(CategoryKey.Rank)
      ).frame(width: 200)
    }
  }
}
