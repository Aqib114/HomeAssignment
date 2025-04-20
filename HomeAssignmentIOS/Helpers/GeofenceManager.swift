//
//  GeofenceManager.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
// GeofenceManager.swift
import Foundation
import CoreLocation
import UserNotifications

class GeofenceManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var geofenceRadius: Double = 1 // Default radius
    static let shared = GeofenceManager()

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // Set high accuracy
        locationManager.requestAlwaysAuthorization()
    }
    
    // Start monitoring geofence for the given location and radius
    func startMonitoringGeofence(for location: CLLocationCoordinate2D, radius: Double, identifier: String) {
        // Check if location services are enabled and authorized
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are not enabled.")
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            let geofenceRegion = CLCircularRegion(center: location, radius: radius, identifier: identifier)
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                locationManager.startMonitoring(for: geofenceRegion)
                self.geofenceRadius = radius
                print("Started monitoring geofence for \(identifier) with radius \(radius).")
            } else {
                print("Geofence monitoring is not available on this device.")
            }
        case .denied, .restricted:
            print("Location services are denied or restricted. Cannot start geofence monitoring.")
        case .notDetermined:
            print("Location authorization status not determined yet.")
        @unknown default:
            print("Unknown location authorization status.")
        }
    }

    // Monitor geofence region for entry
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        print("Entered region: \(circularRegion.identifier)") // Debugging print
        scheduleNotification(for: circularRegion.identifier, isEntering: true)
        saveReminder(for: circularRegion, isEntering: true)

    }

    // Monitor geofence region for exit
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        print("Exited region: \(circularRegion.identifier)") // Debugging print
        scheduleNotification(for: circularRegion.identifier, isEntering: false)
        saveReminder(for: circularRegion, isEntering: false)
    }

    // Schedule the notification based on whether the user entered or exited the region
    private func scheduleNotification(for identifier: String, isEntering: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isEntering ? "Geofence Entered" : "Geofence Exited"
        content.body = "You have \(isEntering ? "entered" : "exited") the geofence region: \(identifier)."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for geofence \(isEntering ? "entry" : "exit").")
            }
        }
    }
    private func saveReminder(for region: CLCircularRegion, isEntering: Bool) {
           let reminder = Reminder(
               id: UUID(),
               name: region.identifier,
               note: isEntering ? "Entered region" : "Exited region",
               lat: region.center.latitude,
               lon: region.center.longitude,
               radius: region.radius
           )
           CoreDataManager.shared.saveReminder(reminder)
       }
}
