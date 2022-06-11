//
//  Demo.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/1.
//

import SwiftUI
import StackNavigationView

struct ChildView: View {
  var sidebar: String
  var level: Int
  var body: some View {
    Text("Child\(sidebar),\(level)")
  }
}

struct rootView: View {
  var title: String
  var body: some View {
    VStack {
      Text("This is the root view of \(title)")
        .font(.system(size: 50))
        .bold()
      Spacer()
        .frame(height: 40)
      StackNavigationLink("Next", destination: ChildView(sidebar: title, level: 1))
    }
    .padding(20)
    .navigationTitle(title)
  }
}

struct Demo2View: View {
  
  @State private var selection: Int? = 0
  
  var body: some View {
    
    NavigationView {
      VStack {
        
        NavigationLink("Apples", destination: rootView(title: "Apples"), tag: 0, selection: $selection)
        NavigationLink("Bananas", destination: rootView(title: "Bananas"), tag: 1, selection: $selection)
        NavigationLink("Clementines", destination: rootView(title: "Clementines"), tag: 2, selection: $selection)
      }
      Text("Empty Selection")
    }
    .frame(minWidth: 600, minHeight: 400)
  }
}


struct DemoView: View {
  
  @State private var selection: Int? = 0
  
  var body: some View {
    
    StackNavigationView(selection: $selection) {
      VStack {
        
        SidebarNavigationLink("Apples", destination: rootView(title: "Apples"), tag: 0, selection: $selection)
        SidebarNavigationLink("Bananas", destination: rootView(title: "Bananas"), tag: 1, selection: $selection)
        SidebarNavigationLink("Clementines", destination: rootView(title: "Clementines"), tag: 2, selection: $selection)
        
        SidebarNavigationLink("Apples-2", destination: rootView(title: "Apples-2"), tag: 0, selection: $selection)
        SidebarNavigationLink("Bananas-2", destination: rootView(title: "Bananas-2"), tag: 1, selection: $selection)
        SidebarNavigationLink("Clementines-2", destination: rootView(title: "Clementines"), tag: 2, selection: $selection)
      }
      Text("Empty Selection")
    }
    .frame(minWidth: 600, minHeight: 400)
  }
}

struct Demo_Previews: PreviewProvider {
  static var previews: some View {
    DemoView()
  }
}



struct PopoverDemoView: View {
  @State private var isVisible = false
      var body: some View {
          Button("Test") {
              isVisible.toggle()
          }
          .background(NSPopoverHolderView(isVisible: $isVisible) {
              Text("I'm in NSPopover")
                  .padding()
          })
      }
}
