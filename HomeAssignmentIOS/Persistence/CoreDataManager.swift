//
//  CoreDataManager.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
//import Foundation
//import CoreData
//
//class CoreDataManager {
//    static let shared = CoreDataManager()
//    let container: NSPersistentContainer
//
//    init() {
//        container = NSPersistentContainer(name: "GeofenceReminder")
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                print("Core Data error: \(error)")
//            }
//        }
//    }
//
//    func saveReminder(_ reminder: Reminder) {
//        let context = container.viewContext
//        let entity = CDReminder(context: context)
//        entity.id = reminder.id
//        entity.name = reminder.name
//        entity.lat = reminder.lat
//        entity.lon = reminder.lon
//        entity.note = reminder.note
//        entity.radius = reminder.radius
//        try? context.save()
//    }
//
//    func fetchReminders() -> [Reminder] {
//        let request = CDReminder.fetchRequest()
//        let reminders = (try? container.viewContext.fetch(request)) ?? []
//        return reminders.map {
//            Reminder(id: $0.id ?? UUID(), name: $0.name ?? "", note: $0.note ?? "", lat: $0.lat, lon: $0.lon, radius: $0.radius)
//        }
//    }
//}

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let context: NSManagedObjectContext

    // Initializing the persistent container and context
    init() {
        let container = NSPersistentContainer(name: "GeofenceReminder")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error.localizedDescription)")
            }
        }
        self.context = container.viewContext
    }

    // Save a new reminder to CoreData
    func saveReminder(_ reminder: Reminder) {
        let entity = CDReminder(context: context)
        entity.id = reminder.id
        entity.name = reminder.name
        entity.note = reminder.note
        entity.lat = reminder.lat
        entity.lon = reminder.lon
        entity.radius = reminder.radius
        
        // Saving context
        do {
            try context.save()
            print("Reminder saved successfully!")
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
        }
    }

    // Fetch all reminders from CoreData and convert to custom model
    func fetchReminders() -> [Reminder] {
        let request: NSFetchRequest<CDReminder> = CDReminder.fetchRequest()
        
        // Fetching reminders and mapping to the custom Reminder model
        do {
            let cdReminders = try context.fetch(request)
            let reminders = cdReminders.map { cdReminder in
                Reminder(
                    id: cdReminder.id ?? UUID(),
                    name: cdReminder.name ?? "",
                    note: cdReminder.note ?? "",
                    lat: cdReminder.lat,
                    lon: cdReminder.lon,
                    radius: cdReminder.radius
                )
            }
            return reminders
        } catch {
            print("Failed to fetch reminders: \(error.localizedDescription)")
            return [] // Return an empty list if fetching fails
        }
    }
}
