//
//  HomeView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/21.
//

import SwiftUI


struct HomeView: View {
  @State private var selection: CategoryKey? = CategoryKey.Rank
  
  var body: some View {
    StackNavigationView(selection: $selection) {
//    NavigationView {
      SideNav(
        selection: $selection
      )
      Text("右侧区域")
    }
    .frame(minWidth: 800, minHeight: 600)
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
  @Environment(\.StackNavigationPush) var StackNavigationPush
  var body: some View {
    ZStack {
      VStack {
        switch currentOption {
        case CategoryKey.Rank:
          RankView()
        case CategoryKey.MySong:
          Button(action: {
            StackNavigationPush(AnyView(TextDiy()), nil)
          }, label: {
            Text("gogoo")
          })
          
        case CategoryKey.PlaySetting:
          Text("设置-2")
        case CategoryKey.PersonInfo:
          Text("个人信息-2")
        default:
          Text("控制面板-默认兜底")
        }
//      }.frame(minWidth: 600, minHeight: 560).background(.white)
      }.frame(minHeight: 560).background(.white)
      SidePlayList()
    }
  }
  
  func TextDiy()  -> some View {
    Text("hahah")
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
