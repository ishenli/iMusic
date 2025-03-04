//
//  SidePlayList.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/10.
//

import SwiftUI
import Tabler

struct SidePlayList: View {
  @StateObject var vm = SidePlayListViewModel.Shared
  @StateObject var vm2: AppViewModel = AppViewModel.Shared
  
  var body: some View {
    if vm.isVisible {
      HStack(alignment: .bottom, spacing: 0) {
        Spacer()
        VStack(alignment: .trailing, spacing: 0) {
          Spacer()
          VStack(alignment: .trailing, spacing: 0) {
            VStack(alignment: .leading) {
              HStack(alignment: .top, spacing: 0){
                Header(title:"当前播放")
                Spacer()
              }
              HStack(alignment: .top, spacing: 0){
                Text("总共\(vm.playlist.count)首").foregroundColor( Color.gray1).font(.system(size: 12)).padding(.top, 2)
                Spacer()
                Text("清空列表").foregroundColor(Color.blue1).font(.system(size: 12)).padding(.top, 2).onTapGesture {
                  vm.empty()
                }
              }
              if vm.playlist.count == 0 {
                HStack(alignment: .center){
                  Text("你还没有添加任何歌曲！").foregroundColor(Color.gray1).padding(.top, 40)
                }
              } else {
                SidePlayListTableView(playlist: $vm.playlist).environmentObject(vm)
              }
              Spacer()
            }.padding(10)
           
          }.frame(width: 420, height: 600).background(Rectangle().fill(.white).shadow(color: Color.gray3, radius: 5, x: -5, y: -5))
        }
      }
    }
  }
}

struct SidePlayListTableView: View {
  @EnvironmentObject var vm : SidePlayListViewModel
  @Binding var playlist: [Track]
  
  var gridItems: [GridItem] = [
    GridItem(.flexible(minimum: 60), alignment: .leading),
    GridItem(.fixed(120), alignment: .leading),
    GridItem(.fixed(70), alignment: .leading),
  ]
  
  typealias Context = TablerContext<Track>
  
  func row(fruit: Track) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        HStack {
          Text(fruit.name).padding(.leading, 10)
              .contextMenu {
                Button("从列表中删除", action: {
                  vm.removeSong([fruit])
                })
              }
          if fruit.isCurrentTrack {
            Image(systemName: "play.square").foregroundColor(Color.primary)
          }
        }
        Text(fruit.artists[0].name).foregroundColor( Color.gray1)
        Text(fruit.durationStr).foregroundColor(Color.gray3)
      }.frame(height: 28)
    }.listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0)) // 影响文字
  }
  
  func rowBackground(fruit: Track) -> some View {
    Rectangle()
      .fill(fruit.index % 2 == 0 ? Color.gray2 : Color.white)
  }
  
  var body: some View {
    TablerList(.init(tablePadding: EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)), row: row,
               rowBackground: rowBackground,
               results: playlist).clipped()
  }
}

struct SidePlayList_Previews: PreviewProvider {
  static let vm: PlayListViewModel = PlayListViewModel()
  static var previews: some View {
    SidePlayList()
  }
}
