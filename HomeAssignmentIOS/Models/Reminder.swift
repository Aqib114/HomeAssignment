//
//  Reminder.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import Foundation
import CoreData

struct Reminder: Identifiable {
    let id: UUID
    let name: String
    let note: String
    let lat: Double
    let lon: Double
    let radius: Double
}
