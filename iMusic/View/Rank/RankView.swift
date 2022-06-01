//
//  RankView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/22.
//

import SwiftUI
import Alamofire
import StackNavigationView

struct RankView: View {
  @ObservedObject var vm = RankViewModel()
  var body: some View {
    ScrollView {
      RankPanelView().task {
        await vm.fetch()
      }.environmentObject(vm)
    }
  }
}


struct RankPanelView: View {
  @EnvironmentObject var vm : RankViewModel
  private var gridItemLayout = [GridItem(.adaptive(minimum: 120, maximum: 160), alignment: .topLeading)]
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Header(title: "各大排行榜")
        HStack {
          Group{
            ForEach(vm.tabItems) {tabItem in
              Text(tabItem.tabName)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .foregroundColor(vm.tabSelect == tabItem.id ? Color.black : Color.gray)
                .onTapGesture {
                  vm.tabClick(id: tabItem.id)
                }
            }
          }.font(.system(size: 14))
          Spacer()
        }.padding(.vertical, 5).padding(.leading, -10)
        if vm.isLoading {
          ProgressView()
        } else {
          LazyVGrid(columns: gridItemLayout, spacing: 0) {
            ForEach(vm.ranks) { rank in
              VStack(alignment: .leading) {
                StackNavigationLink(destination: PlayListView()) {
                  AsyncImage(url: URL(string: rank.imageUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                      .frame(width: 120, height: 120)
                      .clipShape(RoundedRectangle(cornerRadius: 10))
                  } placeholder: {
                    ProgressView().frame(width: 120, height: 120)
                  }
                  
                  Text(rank.name)
                  Spacer().frame(height: 20)
                }
              }
            }
          }
        }
        Spacer()
      }
      .padding(40)
      .frame( minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity)
      .background(Color.white)
    }
  }
}


struct RankView_Previews: PreviewProvider {
  static let vm: RankViewModel = RankViewModel()
  
  static var previews: some View {
    RankPanelView().environmentObject(vm).frame(width: 600)
      .task {
        vm.isLoading = false
        vm.ranks = [
          .init(name: "haomo2",imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg", id: 0, theme: 0),
          .init(name: "haomo1", imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg", id: 0, theme: 0),
        ]
      }
  }
}
