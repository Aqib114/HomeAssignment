//
//  RadiusSelectorView.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import SwiftUI

struct RadiusSelectorView: View {
    var location: Location
    var onSave: (Double, String) -> Void
    
    @State private var radius: Double = 200
    @State private var note: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Geofence for \(location.name)").font(.headline)
            Slider(value: $radius, in: 100...1000, step: 50)
            Text("Radius: \(Int(radius))m")
            TextField("Note", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Save Reminder") {
                onSave(radius, note)
            }
        }
        .padding()
    }
}

