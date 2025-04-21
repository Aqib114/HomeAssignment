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
    @Published var errorMessage: IdentifiableError?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        fetchLocationsFromGitHub()
        configureLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.errorMessage = IdentifiableError(message: "Location permission denied. Please enable it from Settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            self.errorMessage = IdentifiableError(message: "Unknown location authorization status.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        configureLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorMessage = IdentifiableError(message: "Failed to get location: \(error.localizedDescription)")
        print(errorMessage ?? "")
    }
    
    private func fetchLocationsFromGitHub() {
        guard let url = URL(string: "https://raw.githubusercontent.com/Aqib114/locations/refs/heads/main/locations.json")
        else {
            self.errorMessage = IdentifiableError(message: "Invalid URL.")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableError(message: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableError(message: "Invalid response from server.")
                }
                return
            }
            guard let data = data, !data.isEmpty else {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableError(message: "No data received from server.")
                }
                return
            }
            do {
                let decoded = try JSONDecoder().decode([Location].self, from: data)
                DispatchQueue.main.async {
                    self.locations = decoded
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableError(message: "Failed to decode location data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
