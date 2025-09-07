//
//  ParacticeAppApp.swift
//  ParacticeApp
//
//  Created by Waseem Abbas on 06/09/2025.
//

import SwiftUI

@main
struct ParacticeAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NotesView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
