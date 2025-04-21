//
//  ReminderListView.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
import SwiftUI

struct ReminderListView: View {
    @StateObject var viewModel = ReminderViewModel()

    var body: some View {
        VStack {
            if viewModel.reminders.isEmpty {
                Text("No reminders available.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                List(viewModel.reminders) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.name).bold()
                        Text("Radius: \(Int(reminder.radius))m")
                        Text("Note: \(reminder.note)")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadReminders()
        }
    }
}
