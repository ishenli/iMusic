import SwiftUI
import Tabler

struct PlayListTableView: View {
  @EnvironmentObject var vm : PlayListViewModel
  @State var hoverSelectTableRow: Int?
  
  private var gridItems: [GridItem] = [
    GridItem(.fixed(50), alignment: .leading),
    GridItem(.flexible(minimum: 35), alignment: .leading),
    GridItem(.flexible(minimum: 25), alignment: .leading),
    GridItem(.fixed(250), alignment: .leading),
    GridItem(.fixed(80), alignment: .leading),
  ]
  
  private typealias Context = TablerContext<Track>
  
  private func header(ctx: Binding<Context>) -> some View {
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
  
  private func row(fruit: Track) -> some View {
    LazyVGrid(columns: gridItems, alignment: .leading) {
      Group {
        HStack {
          Text("\(fruit.index + 1)").padding(.leading, 10).foregroundColor( Color.init(hex: "BBBBBB"))
          if fruit.isCurrentTrack {
            Image(systemName: "play.square").foregroundColor(.red)
          }
        }
        Text(fruit.name).onTapGesture {
          vm.playOneSong(fruit)
          PlayCore.shared.start([fruit], id: fruit.id)
        }
        Text(fruit.artists[0].name).foregroundColor( Color.init(hex: "666666"))
        Text(fruit.album.name).foregroundColor( Color.init(hex: "666666"))
        Text(fruit.durationStr).foregroundColor( Color.init(hex: "BBBBBB"))
      }.frame(height: 33)
    }
  }
  
  private func rowBackground(fruit: Track) -> some View {
    var color: Color
    if fruit.id == hoverSelectTableRow {
      color = Color.init(hex: "F2F2F3")
    } else {
      color = fruit.index % 2 == 0 ? Color.init(hex: "FAFAFA") : Color.white
    }
    return Rectangle().fill(color)
  }
  private func hoverAction(fruitID: Int, isHovered: Bool) {
    hoverSelectTableRow = fruitID
  }
  var body: some View {
    TablerList(
      .init(onHover: hoverAction),
      header: header,
      row: row,
      rowBackground: rowBackground,
      results: vm.tracks)
  }
}


struct PlayListTableView_Previews: PreviewProvider {
  static let vm: PlayListViewModel = PlayListViewModel()
  static var previews: some View {
    PlayListTableView().environmentObject(vm).task {
      await vm.fetch(id: 3136952023)
    }
  }
}
