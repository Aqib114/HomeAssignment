//
//  HomeAssignmentIOSApp.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import SwiftUI


@main

struct HomeAssignmentIOSApp: App {
    // Attach the AppDelegate here
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init(){
        NotificationManager.shared.requestAuthorization()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
