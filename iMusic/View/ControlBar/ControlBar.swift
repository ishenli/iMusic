//
//  ControlBar.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/27.
//

import SwiftUI

struct ControlBar: View {
  @ObservedObject var vm = ControlBarViewModel()
  
  var imageUrl: String
  
  var body: some View {
    VStack(spacing: 0){
      Rectangle().frame(height: 2).foregroundColor(.blue)
      HStack(alignment: .center, spacing: 0) {
        HStack {
          AsyncImage(url: URL(string: imageUrl)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
              .frame(width: 40, height: 40)
              .clipShape(RoundedRectangle(cornerRadius: 10))
          } placeholder: {
            ProgressView().frame(width: 40, height: 40)
          }
          VStack(alignment: .leading) {
            HStack {
              Text("想你")
              Text("-想你")
            }
            HStack {
              Text("00:00")
              Text("34:00")
            }
          }
        }.padding(.leading, 10)
        Spacer()
        HStack(alignment: .center) {
          Group {
            Image(systemName: "backward.end.alt").padding(.trailing, 15).onTapGesture {
              vm.controlAction(sender: .previousButton)
            }.onHover { inside in
              if inside {
                NSCursor.pointingHand.push()
                } else {
                NSCursor.pop()
              }
            }

            VStack{
              Rectangle().frame(width: 40, height: 40).cornerRadius(20).offset(y: 10)
              Group {
                if !vm.isPlaying {
                  Image(systemName: "play.fill").onTapGesture {
                    vm.controlAction(sender: .pauseButton)
                  }
                  
                } else {
                  Image(systemName: "pause").onTapGesture {
                    vm.controlAction(sender: .playButton)
                  }
                }
              }
              .foregroundColor(.white)
              .aspectRatio(contentMode: .fit)
              .font(.system(size: 20))
              .offset(x: 2, y: -22)
            }
            .onHover { inside in
              if inside {
                NSCursor.pointingHand.push()
                } else {
                NSCursor.pop()
              }
            }
            
            Image(systemName: "forward.end.alt").padding(.leading, 15).onTapGesture {
              vm.controlAction(sender: .nextButton)
            }.onHover { inside in
              if inside {
                NSCursor.pointingHand.push()
                } else {
                NSCursor.pop()
              }
            }
          }.foregroundColor(.red) .font(.system(size: 20))
        }
        Spacer()
        HStack {
          Text("歌词")
        }.padding(.trailing, 30)
      }
      .frame(height: 60)
      .background(.white)
    }
    
  }
}

struct ControlBar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ControlBar(imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg")
    }.frame(width: 600)
    
  }
}
