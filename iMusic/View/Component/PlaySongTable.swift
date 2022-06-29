//
//  Table.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/15.
//

import SwiftUI
import Tabler

struct PlaySongTable: View {
  @State var hoverSelectTableRow: Int?
  @StateObject var vm = SidePlayListViewModel.Shared
  

  var tracks: [Track]
  
  var gridItems: [GridItem] = [
    GridItem(.fixed(15), alignment: .leading),
    GridItem(.flexible(minimum: 35), alignment: .leading),
    GridItem(.fixed(100), alignment: .leading),
    GridItem(.fixed(250), alignment: .leading),
    GridItem(.fixed(80), alignment: .leading),
  ]
  
  typealias Context = TablerContext<Track>
  
 func header(ctx: Binding<Context>) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        Text("")
        Text("音乐标题")
        Text("歌手")
        Text("专辑")
        Text("时长")
      }.frame(height: 35).foregroundColor(Color.gray)
    }
  }
  
  func row(fruit: Track) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        HStack {
//          Text("\(fruit.index + 1)").padding(.leading, 10).foregroundColor( Color.init(hex: "BBBBBB"))
          if fruit.isCurrentTrack {
            Image(systemName: "play.square").foregroundColor(Color.primary).padding([.leading], 5)
          }
        }
        HStack {
          Text(fruit.name)
            .foregroundColor(fruit.playable ? Color.gray1 : Color.gray3)
          .onTapGesture {
            if (fruit.playable) {
              vm.playOneSong(fruit)
            }
          }.contextMenu {
            Button("下一首播放", action: {
              vm.addToPlayList([fruit])
            }).disabled(!fruit.playable)
          }
        }

        Text(fruit.artists[0].name).foregroundColor( Color.gray1)
        Text(fruit.album.name).foregroundColor( Color.gray1)
        Text(fruit.durationStr).foregroundColor( Color.gray3)
      }.frame(height: 33)
    }
  }
  
  func rowBackground(fruit: Track) -> some View {
    var color: Color
    if fruit.id == hoverSelectTableRow {
      color = Color.init(hex: "F2F2F3")
    } else {
      color = fruit.index % 2 == 0 ? Color.init(hex: "FAFAFA") : Color.white
    }
    return Rectangle().fill(color)
  }
  func hoverAction(fruitID: Int, isHovered: Bool) {
    hoverSelectTableRow = fruitID
  }
  var body: some View {
    TablerList(
      .init(onHover: hoverAction,tablePadding: EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)),
      header: header,
      row: row,
      rowBackground: rowBackground,
      results: tracks)
  }
}

//struct Table_Previews: PreviewProvider {
//    static var previews: some View {
////      PlayTable( tracks: [Track()])
//    }
//}
