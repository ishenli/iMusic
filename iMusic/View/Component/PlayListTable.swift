//
//  Table.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/15.
//

import SwiftUI
import Tabler

struct PlayListTable: View {
  @State var hoverSelectTableRow: Int?
  
  var playList: [SearchPlayList]
  
  var gridItems: [GridItem] = [
    GridItem(.fixed(20), alignment: .leading),
    GridItem(.flexible(minimum: 200), alignment: .leading),
    GridItem(.fixed(80), alignment: .leading),
    GridItem(.fixed(80), alignment: .leading),
    GridItem(.fixed(80), alignment: .leading),
  ]
  
  typealias Context = TablerContext<SearchPlayList>
  
  func header(ctx: Binding<Context>) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        Text("")
        Text("歌单名称")
        Text("歌单作者")
        Text("歌曲数")
        Text("播放量")
      }.frame(height: 35).foregroundColor(Color.gray)
    }
  }
  
  func row(fruit: SearchPlayList) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        Text("")
        HStack {
          AsyncImage(url: fruit.picUrl) { image in
            image.resizable().aspectRatio(contentMode: .fill)
              .frame(width: 60, height: 60)
              .clipShape(RoundedRectangle(cornerRadius: 5))
          } placeholder: {
            ProgressView().frame(width: 60, height: 60)
          }
          Text(fruit.name)
        }
        Text(fruit.Creator.nickname).foregroundColor( Color.init(hex: "666666"))
        Text("\(fruit.trackCount)").foregroundColor( Color.init(hex: "666666"))
        Text("\(fruit.playCount)").foregroundColor( Color.init(hex: "BBBBBB"))
      }.frame(height: 70)
    }
  }
  
  func rowBackground(fruit: SearchPlayList) -> some View {
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
    
    if playList.count == 0 {
      Text("暂无歌单")
    } else {
      TablerList(
        .init(onHover: hoverAction,tablePadding: EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: -20)),
        header: header,
        row: row,
        rowBackground: rowBackground,
        results: playList)
    }
    
  }
}

struct Table_Previews: PreviewProvider {
  static var previews: some View {
    PlayListTable( playList: [SearchPlayList(id: 0, picUrl: URL(string: "http://img1.kwcdn.kuwo.cn/star/userpl2015/81/23/1568684821020_182253281_700.jpg")!, playCount: 10, name: "终于等到周杰伦，说好不哭你今天哭了吗？", Creator: Creator(nickname: "皓默", userId: 99, avatarUrl: URL(string: AVATAR_DEFAULT)!), trackCount: 1000, index: 1),SearchPlayList(id: 1, picUrl: URL(string: "http://img1.kwcdn.kuwo.cn/star/userpl2015/81/23/1568684821020_182253281_700.jpg")!, playCount: 10, name: "终于等到周杰伦，说好不哭你今天哭了吗？", Creator: Creator(nickname: "皓默", userId: 99, avatarUrl: URL(string: AVATAR_DEFAULT)!), trackCount: 1000, index: 1)])
  }
}
