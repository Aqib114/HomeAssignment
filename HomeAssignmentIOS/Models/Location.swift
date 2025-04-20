//
//  Location.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//

import Foundation
import CoreLocation

struct Location: Codable, Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let category: String
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


