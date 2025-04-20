//
//  LocationViewModel.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
import Foundation
import CoreLocation
import Combine
import UserNotifications

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locations: [Location] = []
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        fetchLocationsFromGitHub()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location:", error.localizedDescription)
    }
    
    private func fetchLocationsFromGitHub() {
           guard let url = URL(string: "https://raw.githubusercontent.com/Aqib114/locations/refs/heads/main/locations.json") else { return }

           URLSession.shared.dataTask(with: url) { data, _, error in
               if let data = data {
                   do {
                       let decoded = try JSONDecoder().decode([Location].self, from: data)
                       DispatchQueue.main.async {
                           self.locations = decoded
                       }
                   } catch {
                       print("Decoding failed: \(error)")
                   }
               } else if let error = error {
                   print("Network error: \(error)")
               }
           }.resume()
       }
}
