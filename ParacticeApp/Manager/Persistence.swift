//
//  Persistence.swift
//  ParacticeApp
//
//  Created by Waseem Abbas on 06/09/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ParacticeApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    func save () async {
        if context.hasChanges {
            do {
                try context.save()
            } catch  {
                print("Core data save errors \(error.localizedDescription)")
            }
        }
    }
}
