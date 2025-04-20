//
//  MapView.swift
//  HomeAssignmentIOS
//
//  Created by Mapple.pk on 18/04/2025.
//
//import SwiftUI
//import MapKit
//import CoreLocation
//
//struct MapView: View {
//    @StateObject private var viewModel = LocationViewModel()
//    @State private var shouldFollowUser = true
//
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
//        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//    )
//    
//    @State private var selectedLocation: CLLocationCoordinate2D? = nil
//    @State private var geofenceRadius: CLLocationDistance? = nil
//    @State private var selectedLocationPoint: CGPoint? = nil
//    private var mapView = MKMapView()
//
//    var body: some View {
//        ZStack {
//            Map(coordinateRegion: $region,
//                showsUserLocation: true,
//                annotationItems: viewModel.locations
//            ) { item in
//                MapAnnotation(coordinate: item.coordinate) {
//                    VStack {
//                        Image(systemName: "mappin.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.red)
//                            .onTapGesture {
//                                selectedLocation = item.coordinate
//                                updateSelectedLocationPoint(coordinate: item.coordinate)
//                                showGeofenceOptions()
//                            }
//                        Text(item.name)
//                            .font(.caption)
//                            .bold()
//                            .background(Color.white.opacity(0.7))
//                    }
//                }
//            }
//            .onAppear {
//                if let userLocation = viewModel.userLocation {
//                    region.center = userLocation
//                }
//            }
//            .onChange(of: viewModel.userLocation ?? region.center) { newLocation in
//                if shouldFollowUser {
//                    region.center = newLocation
//                }
//            }
//            .edgesIgnoringSafeArea(.all)
//            
//            if viewModel.userLocation == nil {
//                ProgressView("Fetching Location...")
//            }
//            
//            // Draw geofence circle only if location is selected
//            if let radius = geofenceRadius, let location = selectedLocation, let centerPoint = selectedLocationPoint {
//                Circle()
//                    .strokeBorder(Color.red, lineWidth: 2)  // Border for the circle
//                    .background(Circle().fill(Color.red.opacity(0.3)))  // Red fill with opacity
//                    .frame(width: radius * 2, height: radius * 2)  // Set size based on radius
//                    .position(centerPoint)
//            }
//            
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        shouldFollowUser.toggle()
//                    }) {
//                        Image(systemName: shouldFollowUser ? "location.fill" : "location.slash")
//                            .padding()
//                            .background(Color.white)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding()
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//    }
//    
//    private func updateSelectedLocationPoint(coordinate: CLLocationCoordinate2D) {
//        // Convert the CLLocationCoordinate2D to a CGPoint using the mapView's method
//        let point = mapView.convert(coordinate, toPointTo: mapView)
//        selectedLocationPoint = point
//    }
//    
//    private func showGeofenceOptions() {
//        // Present options to choose radius
//        let actionSheet = UIAlertController(title: "Set Geofence Radius", message: "Choose a radius for the geofence", preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title: "100 meters", style: .default, handler: { _ in
//            geofenceRadius = 100
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "500 meters", style: .default, handler: { _ in
//            geofenceRadius = 500
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        if let rootController = UIApplication.shared.windows.first?.rootViewController {
//            rootController.present(actionSheet, animated: true)
//        }
//    }
//}
//
//extension CLLocationCoordinate2D: Equatable {
//    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//    }
//}
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = LocationViewModel()
    @State private var shouldFollowUser = true

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var geofenceRadius: CLLocationDistance? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Map is at the bottom of the ZStack
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: viewModel.locations
                ) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .onTapGesture {
                                    selectedLocation = item.coordinate
                                    showGeofenceOptions()
                                }
                            Text(item.name)
                                .font(.caption)
                                .bold()
                                .background(Color.white.opacity(0.7))
                        }
                    }
                }
                .onAppear {
                    if let userLocation = viewModel.userLocation {
                        region.center = userLocation
                    }
                }
                .onChange(of: viewModel.userLocation ?? region.center) { newLocation in
                    if shouldFollowUser {
                        region.center = newLocation
                    }
                }
                .edgesIgnoringSafeArea(.all)

                // Circle is drawn on top of the map but should not block interaction
                if let radius = geofenceRadius, let selected = selectedLocation {
                    let circleSize = calculateCircleSize(radius: radius, geo: geo.size)
                    let mapPoint = convertCoordinateToCGPoint(selected, in: region, frameSize: geo.size)

                    Circle()
                        .strokeBorder(Color.red, lineWidth: 2)
                        .background(Circle().fill(Color.red.opacity(0.3)))
                        .frame(width: circleSize, height: circleSize)
                        .position(mapPoint)
                        .allowsHitTesting(false) // Prevent circle from blocking map interaction
                }

                if viewModel.userLocation == nil {
                    ProgressView("Fetching Location...")
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            shouldFollowUser.toggle()
                        }) {
                            Image(systemName: shouldFollowUser ? "location.fill" : "location.slash")
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }

    private func showGeofenceOptions() {
        let actionSheet = UIAlertController(title: "Set Geofence Radius", message: "Choose a radius for the geofence", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "100 meters", style: .default, handler: { _ in
            geofenceRadius = 20
            startGeofenceMonitoring()
        }))
        actionSheet.addAction(UIAlertAction(title: "500 meters", style: .default, handler: { _ in
            geofenceRadius = 50
            startGeofenceMonitoring()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let root = UIApplication.shared.windows.first?.rootViewController {
            root.present(actionSheet, animated: true)
        }
    }

    private func startGeofenceMonitoring() {
        if let selectedLocation = selectedLocation, let radius = geofenceRadius {
            // Start monitoring geofence for the selected location
            GeofenceManager.shared.startMonitoringGeofence(for: selectedLocation, radius: radius, identifier: "Geofence-\(selectedLocation.latitude)-\(selectedLocation.longitude)")
        }
    }


    // Meters per point (approximate based on latitudeDelta and screen width)
    private func calculateCircleSize(radius: CLLocationDistance, geo: CGSize) -> CGFloat {
        let metersPerPoint = metersPerPointAtLatitude(latitude: region.center.latitude, latitudeDelta: region.span.latitudeDelta, screenWidth: geo.width)
        return CGFloat(radius / metersPerPoint)
    }

    private func metersPerPointAtLatitude(latitude: CLLocationDegrees, latitudeDelta: CLLocationDegrees, screenWidth: CGFloat) -> CLLocationDistance {
        let earthCircumference: CLLocationDistance = 40_075_000 // meters
        let metersPerDegree = earthCircumference / 360.0
        let mapWidthInMeters = latitudeDelta * metersPerDegree
        return mapWidthInMeters / screenWidth
    }

    // Convert coordinate to CGPoint in the map frame
    private func convertCoordinateToCGPoint(_ coordinate: CLLocationCoordinate2D, in region: MKCoordinateRegion, frameSize: CGSize) -> CGPoint {
        let latRatio = (region.center.latitude - coordinate.latitude) / region.span.latitudeDelta
        let lonRatio = (coordinate.longitude - region.center.longitude) / region.span.longitudeDelta

        let x = (frameSize.width / 2) + (lonRatio * frameSize.width)
        let y = (frameSize.height / 2) + (latRatio * frameSize.height)

        return CGPoint(x: x, y: y)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
