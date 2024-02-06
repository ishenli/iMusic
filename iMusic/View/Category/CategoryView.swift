//
//  CategoryView.swift
//  iMusic
//
//  Created by michael.sl on 2022/7/4.
//

import SwiftUI

struct CategoryView: View {
  @StateObject var vm = RankViewModel.Shared
  
  private var gridItemLayout = [GridItem(.adaptive(minimum: 120, maximum: 160), alignment: .topLeading)]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Header(title: "热门分类").padding(.bottom, 10)
        VStack(spacing:5){
          ForEach(0..<3) { a in
            HStack {
              Text("要是否").font(Font.headline)
              HStack {
                Group {
                  ForEach(0..<6) { b in
                    Text("要是否")
                  }
                }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing:10))

              }
              Spacer()
            }
          }
        
        }
        Spacer()
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
      }
      .padding(40)
      .frame(minWidth: 500, minHeight: 600)
    }
  }
}

struct CategoryView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryView()
  }
}
