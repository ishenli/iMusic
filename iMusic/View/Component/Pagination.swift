//
//  Pagination.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/15.
//
import Foundation
import SwiftUI

protocol PaginationProtocol {
  func onChange(page: Int, pageSize: Int)
}

struct Pagination: View {
  var defaultCurrent: Int = 1
  var pageSize: Int = 20
  var vm: PaginationProtocol = Pg()
  @State var current = 1;
  
  var body: some View {
    HStack {
      Text("前一页").onTapGesture {
        current = current - 1
        vm.onChange(page: current, pageSize: pageSize)
      }
      Text("current:\(current)")
      Text("下一页").onTapGesture {
        current = current + 1
        vm.onChange(page: current, pageSize: pageSize)
      }
    }
  }
}
struct Pg: PaginationProtocol {
  func onChange(page: Int, pageSize: Int) {
    print(page)
  }
}


struct Pagination_Previews: PreviewProvider {
  static var pg: PaginationProtocol = Pg();
  static var previews: some View {
    Pagination(vm: pg)
  }
}
