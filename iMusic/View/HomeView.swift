//
//  HomeView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/21.
//

import SwiftUI
import StackNavigationView

struct HomeView: View {
  @State private var selection: CategoryKey? = CategoryKey.Rank
  
  var body: some View {
    StackNavigationView(selection: $selection) {
      SideNav(
        selection: $selection
      )
      Text("右侧区域")
    }
    ControlBar(imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg").padding(.top, -10.0)
  }
}


struct MyTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(30)
      .background(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(Color.red, lineWidth: 3)
      ).padding()
  }
}


struct MainView: View {
  var currentOption: CategoryKey;
  var body: some View {
    ZStack {
      VStack {
        switch currentOption {
        case CategoryKey.Rank:
          RankView()
        case CategoryKey.MySong:
          Text("我的歌单-1")
        case CategoryKey.PlaySetting:
          Text("设置-2")
        case CategoryKey.PersonInfo:
          Text("个人信息-2")
        default:
          Text("控制面板-默认兜底")
        }
      }.frame(minWidth: 800, minHeight: 560).background(.white)
      SidePlayList()
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
