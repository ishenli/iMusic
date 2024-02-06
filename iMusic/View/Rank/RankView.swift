//
//  RankView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/22.
//

import SwiftUI
import Alamofire

struct RankView: View {
  @StateObject var vm = RankViewModel.Shared
  var body: some View {
    GeometryReader { geo in
//      Text("w: \(geo.size.width, specifier: "%.1f")  h: \(geo.size.height, specifier: "%.1f")")
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
                .foregroundColor(vm.tabSelect == tabItem.tag ? Color.black : Color.gray)
                .onTapGesture {
                  vm.platformTabClick(id: tabItem.tag)
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
                StackNavigationLink(destination: PlayListView(query: PlayListViewQuery(id: rank.id, platform: vm.tabSelect))) {
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
      .frame(minWidth: 500,
              minHeight: 600)
    }
  }
}


struct RankView_Previews: PreviewProvider {
  static let vm: RankViewModel = RankViewModel()
  
  static var previews: some View {
    RankPanelView().frame(width: 600).environmentObject(vm)
      .task {
        vm.isLoading = false
        vm.ranks = [
          .init(name: "haomo2",imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg", id: 0, theme: 0),
          .init(name: "haomo1", imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg", id: 0, theme: 0),
        ]
      }
  }
}
