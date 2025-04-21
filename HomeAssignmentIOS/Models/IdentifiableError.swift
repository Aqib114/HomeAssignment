//
//  IdentifiableError.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 21/04/2025.
//

import Foundation

struct IdentifiableError: Identifiable {
    var id = UUID()
    var message: String
}
