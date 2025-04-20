//
//  ReminderViewModel.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
import Foundation

class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []  // List of reminders that will be observed by the view
    private let coreData = CoreDataManager.shared  // CoreDataManager instance to interact with CoreData
    
    init() {
        loadReminders()  // Load reminders when the view model is initialized
    }
    
    // Load reminders from CoreData
    func loadReminders() {
        reminders = coreData.fetchReminders()  // Fetch reminders using CoreDataManager
        // If no reminders are found, you can handle the logic here if needed, like logging or showing an alert
    }

    // Add a reminder to CoreData and refresh the list
    func addReminder(_ reminder: Reminder) {
        coreData.saveReminder(reminder)  // Save the reminder to CoreData
        loadReminders()  // Reload the reminders after adding a new one to update the UI
    }
    
    // You could also add a deleteReminder function here if needed for deleting reminders.
}
