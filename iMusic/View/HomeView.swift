//
//  HomeView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/21.
//

import SwiftUI
import StackNavigationView

struct HomeView: View {
  @State var currentOption = CategoryKey.Rank;
  @State private var selection: Int? = 0
  
  var body: some View {
    StackNavigationView(selection: $selection) {
      SideNav(
        currentSelection: $currentOption,
        selection: $selection
      )
      Text("右侧区域")
    }
    .frame(minWidth: 600, maxWidth: 980, minHeight: 400)
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
  var currentOption: Int
  var body: some View {
    switch currentOption {
    case 0:
      RankView()
    case 1:
      Text("我的歌单")
    case 3:
      Text("设置")
    default:
      Text("控制面板-默认兜底")
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
