import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let context: NSManagedObjectContext
    
    init() {
        let container = NSPersistentContainer(name: "GeofenceReminder")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error.localizedDescription)")
            }
        }
        self.context = container.viewContext
    }
    
    func saveReminder(_ reminder: Reminder) {
        let entity = CDReminder(context: context)
        entity.id = reminder.id
        entity.name = reminder.name
        entity.note = reminder.note
        entity.lat = reminder.lat
        entity.lon = reminder.lon
        entity.radius = reminder.radius
        do {
            try context.save()
            print("Reminder saved successfully!")
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
        }
    }
    
    func fetchReminders() -> [Reminder] {
        let request: NSFetchRequest<CDReminder> = CDReminder.fetchRequest()
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
            return []
        }
    }
}
