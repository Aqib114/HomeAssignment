import Foundation
import CoreLocation
import UserNotifications

class GeofenceManager: NSObject, CLLocationManagerDelegate {
    static let shared = GeofenceManager()
    private var locationManager: CLLocationManager
    private var monitoredRegions: [String: (name: String, coordinate: CLLocationCoordinate2D, radius: Double)] = [:]
    private var regionStatus: [String: Bool] = [:]
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func startManualMonitoring(name: String,for location: CLLocationCoordinate2D, radius: Double, identifier: String, coordinates : CLLocationCoordinate2D) {
        monitoredRegions[identifier] = (name: name, coordinate: location, radius: radius)
        monitoredRegions[identifier] = nil
        regionStatus[identifier] = nil
        if let currentLocation = locationManager.location {
            let distance = currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
            let isInside = distance <= radius
            regionStatus[identifier] = isInside
            print("User is currently \(isInside ? "inside" : "outside") new geofence: \(identifier)")
            scheduleNotification(for: name, isEntering: isInside)
        }
        print("Started monitoring: \(identifier) with radius: \(radius)m")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        for (identifier, (name, center, radius)) in monitoredRegions {
            let geofenceLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let distance = currentLocation.distance(from: geofenceLocation)
            let isCurrentlyInside = distance <= radius
            let wasInside = regionStatus[identifier] ?? false
            if isCurrentlyInside != wasInside {
                regionStatus[identifier] = isCurrentlyInside
                print("\(isCurrentlyInside ? "Entered" : "Exited") geofence: \(identifier)")
                scheduleNotification(for: name, isEntering: isCurrentlyInside)
            }
        }
    }
    
    func beginTrackingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            let status = locationManager.authorizationStatus
            handleAuthorizationStatus(status)
        } else {
            print("Location services not enabled.")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        handleAuthorizationStatus(status)
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("Location access denied or restricted.")
        @unknown default:
            break
        }
    }
    
    private func scheduleNotification(for identifier: String, isEntering: Bool) {
        let content = UNMutableNotificationContent()
        content.title = isEntering ? "Geofence Entered" : "Geofence Exited"
        content.body = "You have \(isEntering ? "entered" : "exited") the geofence: \(identifier)"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            } else {
                print("Notification scheduled for \(identifier)")
            }
        }
    }
    
    private func saveReminder(name: String, for center: CLLocationCoordinate2D, radius: Double, identifier: String, isEntering: Bool, coordinates: CLLocationCoordinate2D) {
        let reminder = Reminder(
            id: UUID(),
            name: name,
            note: isEntering ? "Entered region" : "Exited region",
            lat: center.latitude,
            lon: center.longitude,
            radius: radius
        )
        CoreDataManager.shared.saveReminder(reminder)
    }
}
