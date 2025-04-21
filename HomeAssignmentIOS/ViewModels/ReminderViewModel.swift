//
//  ReminderViewModel.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
import Foundation

class ReminderViewModel: ObservableObject {
    
    @Published var reminders: [Reminder] = []
    private let coreData = CoreDataManager.shared
    
    init() {
        loadReminders()
    }
    
    func loadReminders() {
        reminders = coreData.fetchReminders()
    }

    func addReminder(_ reminder: Reminder) {
        coreData.saveReminder(reminder)
        loadReminders()
    }
}
