//
//  LocationPermissionManager.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import Foundation
import CoreLocation
class LocationPermissionManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?


    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest


    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            // Handle permission denied
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get location: \(error.localizedDescription)")
        }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let loc = locations.last else { return }
           DispatchQueue.main.async {
               self.location = loc
           }
       }

}
