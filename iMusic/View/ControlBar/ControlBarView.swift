//
//  ControlBar.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/27.
//

import SwiftUI

struct ControlBar: View {
  @ObservedObject var vm = ControlBarViewModel.shared
  @State private var showVolumePanel: Bool = false
  
  var imageUrl: String
  
  var body: some View {
    VStack(spacing: 5){
      Slider(value: $vm.durationSlider.doubleValue, in: 0...vm.durationSlider.maxValue, onEditingChanged: vm.changePlaySlider).accentColor(.red).disabled(vm.durationSlider.maxValue == 0).frame(height: 10)
      HStack(alignment: .center, spacing: 0) {
        HStack(alignment: .top) {
          if vm.trackPicButton != "" {
            AsyncImage(url: URL(string: vm.trackPicButton)) { image in
              image.resizable().aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
              ProgressView().frame(width: 40, height: 40)
            }
          }
          VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
              if !vm.trackNameTextField.isHidden {
                Text(vm.trackNameTextField.text)
              }
              if !vm.trackSecondNameTextField.isHidden {
                Text(" - ").withGrayColorFormatting()
                Text(vm.trackSecondNameTextField.text).withGrayColorFormatting()
              }
            }.padding(.bottom, 5)
            HStack {
              if !vm.durationTextField.isHidden {
                Text(vm.durationTextField.text).withGrayColorFormatting()
              }
            }
          }
          Spacer()
        }.padding(.leading, 10).frame(width: 350)
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
            
            ZStack{
              Rectangle().frame(width: 40, height: 40).cornerRadius(20)
              Group {
                if !vm.isPlaying {
                  Image(systemName: "play.fill")
                } else {
                  Image(systemName: "pause")
                }
              }
              .foregroundColor(.white)
              .aspectRatio(contentMode: .fit)
              .font(.system(size: 20))
            }
            .onHover { inside in
              if inside {
                NSCursor.pointingHand.push()
              } else {
                NSCursor.pop()
              }
            }.onTapGesture {
              vm.controlAction(sender: vm.isPlaying ? .playButton : .pauseButton)
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
        }.frame(width: 200)
        Spacer()
        HStack(alignment: .bottom, spacing: 20) {
          Spacer()
          Group {
            Image(systemName: "newspaper").onTapGesture {
              SidePlayListViewModel.Shared.isVisible.toggle()
            }.font(.system(size: 16))
            Image(systemName: "speaker").foregroundColor(vm.muteButton.contentTintColor).onTapGesture {
              vm.controlAction(sender: .muteButton)
            }.onHover(perform: { hovering in
              if hovering {
                showVolumePanel = true
              }
            })
            .popover(isPresented: $showVolumePanel) {
              VStack {
                Slider(value: $vm.volumeSlider.floatValue, in: 0...1, onEditingChanged: vm.changeVolume).accentColor(.red).frame(height: 10)
                  .padding(10)
              }.frame(width: 150)
            }
            Image(systemName: "list.triangle").onTapGesture {
              SidePlayListViewModel.Shared.isVisible.toggle()
            }
          }.font(.system(size: 18))
   
        }.frame(width:280).padding(.trailing, 20)
      }
    }
    .frame(height: 70)
    .background(.white)
  }
}



struct ControlBar_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ControlBar(imageUrl: "http://imge.kugou.com/v2/mobile_class_banner/6f96931ffde89cd1860cd2f9af1b39f2.jpg")
    }.frame(width: 750)
    
  }
}
