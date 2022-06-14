//
//  PlayListView.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/29.
//

import SwiftUI

struct PlayListView: View {
  @StateObject var vm = PlayListViewModel.Shared
  
  var id: Int
  
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        if vm.isLoading {
          ProgressView()
            .frame(width: 400, height: 400)
        } else {
          PlayListHeaderView().environmentObject(vm)
          PlayListTableView().environmentObject(vm)
        }
      }.frame(minWidth: 600, minHeight: 560).background(.white)
      .task {
        await vm.fetch(id: id)
      }
      SidePlayList()
    }
  }
}

struct ButtonStyleModifider: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(width: 120, height:36)
      .foregroundColor(.white)
      .withCursorStyle()
  }
}

struct PlayListHeaderView: View {
  @EnvironmentObject var vm : PlayListViewModel
  //  var id: Int
  var body: some View {
    if (vm.playList != nil) {
      
      HStack(spacing:0) {
      // "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg
      AsyncImage(url: vm.playList?.coverImgUrl) { image in
        image.resizable().aspectRatio(contentMode: .fill)
          .frame(width: 200, height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } placeholder: {
        ProgressView().frame(width: 200, height: 200)
      }.padding(.horizontal, 20)
      VStack(alignment: .leading) {
        HStack(alignment: .top,spacing: 10) {
          Text(" 歌单 ")
            .border(.red, width: 1)
            .foregroundColor(.red)
            .cornerRadius(3)
            .frame(height: 28)
            .offset(x: 0, y: 4)
          Text(vm.playList!.name)
            .font(.system(size: 26, weight: .bold))
            .padding(.bottom, 15)
          Spacer()
        }.padding(.top, 10).frame(height: 32)
        HStack {
          AsyncImage(url: (vm.playList?.creator?.avatarUrl)!){ image in
            image.resizable().aspectRatio(contentMode: .fill)
              .frame(width: 20, height: 20)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          } placeholder: {
            ProgressView().frame(width: 20, height: 20)
          }

          Text((vm.playList?.creator!.nickname)!)
            .font(.system(size: 14))
            .foregroundColor(Color.blue)
          
          Text("\(vm.playList!.createTimeStr!) 创建")
            .font(.system(size: 14))
            .foregroundColor(Color.gray)
          Spacer()
        }.padding(.vertical, 10)
        HStack {
          Group {
            Button(action: vm.playAll) {
              Label("播放全部", systemImage: "folder.badge.plus")
                .modifier(ButtonStyleModifider())
                .background(.red)
                .cornerRadius(10)
            }
//            Button(action: vm.playAll) {
//              Label("下载全部", systemImage: "square.and.arrow.down")
//                .modifier(ButtonStyleModifider())
//                .background(.blue)
//                .cornerRadius(16)
//            }
          }
          .buttonStyle(PlainButtonStyle())
          
          
          Spacer()
        }.padding(.bottom, 15)
        VStack(alignment: .leading, spacing:10) {
          HStack {
            Text("标签:")
            ForEach((vm.playList?.tags)!, id: \.self) {tag in
              Text(tag).foregroundColor(.blue)
            }
            Spacer()
          }
          HStack {
            Text("歌曲数:")
            Text(String(vm.playList!.trackCount)).foregroundColor(.gray)
            Text("播放数")
            Text(String(vm.playList!.playCount)).foregroundColor(.gray)
            Spacer()
          }
          HStack {
            Text("简介:")
            Text((vm.playList?.description)!).foregroundColor(.gray)
            Spacer()
          }
        }
        Spacer()
      }.frame(height: 200)
    }.frame(height: 250).background(Color.white)
    }
    
  }
}

struct PlayListView_Previews: PreviewProvider {
//  static let vm: PlayListViewModel = PlayListViewModel()
  static var previews: some View {
    PlayListView(id: 3136952023).frame(width: 600, height: 600)
  }
}
