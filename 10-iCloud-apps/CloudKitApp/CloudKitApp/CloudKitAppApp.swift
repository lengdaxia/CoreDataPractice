//
//  CloudKitAppApp.swift
//  CloudKitApp
//
//  Created by leng on 2021/07/12.
//

import SwiftUI

@main
struct CloudKitAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
