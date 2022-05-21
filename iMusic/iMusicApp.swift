//
//  iMusicApp.swift
//  iMusic
//
//  Created by michael.sl on 2022/5/21.
//

import SwiftUI

@main
struct iMusicApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
