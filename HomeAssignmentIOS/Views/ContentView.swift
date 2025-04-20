//
//  ContentView.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem { Label("Map", systemImage: "map") }
            
            ReminderListView()
                .tabItem { Label("Reminders", systemImage: "list.bullet") }
        }
        .accentColor(.blue) 
        .background(.white)
    }
}
