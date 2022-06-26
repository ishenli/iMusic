import SwiftUI


struct PlayListTableView: View {
  @EnvironmentObject var vm : PlayListViewModel
  var body: some View {
    PlayTable(tracks: vm.tracks).padding(.horizontal, 20)
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
