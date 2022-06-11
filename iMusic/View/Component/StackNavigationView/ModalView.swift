//
//  ModalView.swift
//  iMusic
//
//  Created by michael.sl on 2022/6/5.
//

import SwiftUI

struct ModalView: Equatable {
    
    var item: Binding<Int?>
    var content: AnyView
    
    static func == (lhs: ModalView, rhs: ModalView) -> Bool { lhs.item.wrappedValue == rhs.item.wrappedValue }
    
}
