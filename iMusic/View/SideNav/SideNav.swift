//
//  SideNav.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/27.
//

import SwiftUI
import StackNavigationView

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
    ])
  ]
  
  @Binding var currentSelection: CategoryKey
  @Binding var selection: Int?;
  
  var body: some View {
    VStack {
      Spacer()
        .frame(minWidth: 200, maxHeight: 14)
      UserSearchView()
      VStack(
        alignment: .leading
      ) {
        ForEach((works), id: \.self) { option in
          CategoryView (
            workItem: option,
            currentSelection: $currentSelection,
            selection: $selection
          )
        }
      }
      .padding(10)
      .frame(minWidth: 200, maxWidth: 300, alignment: .topLeading)
      Spacer()
    }
    
  }
}


struct CategoryView : View {
  var workItem: WorkItem
  @Binding var currentSelection: CategoryKey
  @Binding var selection: Int?;
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack{
        Text(workItem.title)
          .font(.system(size: 12))
          .foregroundColor(Color.gray)
      }
      ForEach(Array(workItem.categoryList.enumerated()), id: \.offset) { index, option in
        VStack(alignment: .leading) {
          SidebarNavigationLink(destination: MainView(currentOption: selection!), tag: index, selection: $selection) {
            HStack {
              Image(systemName: option.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:14, height: 14)
                .foregroundColor(Color.red)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
              Text(option.title)
              Text(String(selection!))
              Text(String(index))
              Spacer()
            }
            .frame(width:180, height: 30)
            .contentShape(Rectangle())
            .background(index == selection ? .init(hex:"C7C5CA"): Color.gray.opacity(0))
            .cornerRadius(5)
          }
          .buttonStyle(PlainButtonStyle())
        }
        .padding(0)
      }
    }
  }
}


struct UserSearchView: View {
  @State private var username: String = ""
  @FocusState private var emailFieldIsFocused: Bool
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
      TextField(
        "Search",
        text: $username
      )
      .focused($emailFieldIsFocused)
      .onSubmit {
        print(username)
      }
      .frame(height: 28)
      .textFieldStyle(PlainTextFieldStyle())
    }
    .padding([.horizontal], 8)
    .background(Color.init(hex:"C7C5CA"))
    .cornerRadius(4)
    .padding([.horizontal], 8)
    //    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray).background(Color.init(hex:"C7C5CA")).zIndex(1))
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
    
    SideNav(
      currentSelection: .constant(CategoryKey.Rank),
      selection: .constant(0)
    ).frame(width: 200)
  }
}
