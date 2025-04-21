
import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var viewModel = LocationViewModel()
    @State private var shouldFollowUser = true
    @State private var showRadiusSelector = false
    @State private var tempRadius: Double = 50
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var selectedLocation: CLLocationCoordinate2D? = nil
    @State private var geofenceRadius: CLLocationDistance? = nil
    @State private var selectedLocationName: String?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.ignoresSafeArea()
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
                                    selectedLocationName = item.name
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
                    GeofenceManager.shared.beginTrackingLocation()
                }
                .onChange(of: viewModel.userLocation ?? region.center) {
                    if let newLocation = viewModel.userLocation, shouldFollowUser {
                        region.center = newLocation
                    }
                }
                if let radius = geofenceRadius, let selected = selectedLocation {
                    let circleSize = calculateCircleSize(radius: radius, geo: geo.size)
                    let mapPoint = convertCoordinateToCGPoint(selected, in: region, frameSize: geo.size)
                    Circle()
                        .strokeBorder(Color.red, lineWidth: 2)
                        .background(Circle().fill(Color.red.opacity(0.3)))
                        .frame(width: circleSize, height: circleSize)
                        .position(mapPoint)
                        .allowsHitTesting(false)
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
                if showRadiusSelector {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showRadiusSelector = false
                        }
                    VStack(spacing: 20) {
                        Text("Select Custom Radius")
                            .font(.headline)
                        CircularRadiusSelector(radius: $tempRadius, maxRadius: 1000)
                        HStack(spacing: 20) {
                            Button("Cancel") {
                                showRadiusSelector = false
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            
                            Button("Set Radius") {
                                geofenceRadius = tempRadius
                                startGeofenceMonitoring()
                                showRadiusSelector = false
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .frame(width: 300)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                }
            }
        }
        .alert(item: $viewModel.errorMessage) { error in
            if error.message.contains("Location permission denied") {
                return Alert(
                    title: Text("Permission Required"),
                    message: Text(error.message),
                    primaryButton: .default(Text("Open Settings"), action: {
                        openAppSettings()
                    }),
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(
                    title: Text("Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }

    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    private func showGeofenceOptions() {
        let actionSheet = UIAlertController(
            title: "Set Geofence Radius",
            message: "Choose a radius for the geofence",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "100 meters", style: .default, handler: { _ in
            geofenceRadius = 100
            startGeofenceMonitoring()
        }))
        actionSheet.addAction(UIAlertAction(title: "500 meters", style: .default, handler: { _ in
            geofenceRadius = 500
            startGeofenceMonitoring()
        }))
        actionSheet.addAction(UIAlertAction(title: "Custom Radius...", style: .default, handler: { _ in
            tempRadius = 100
            showRadiusSelector = true
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(actionSheet, animated: true)
        }
    }
    
    private func startGeofenceMonitoring() {
        if let selectedLocation = selectedLocation, let radius = geofenceRadius {
            GeofenceManager.shared.startManualMonitoring(
                name: selectedLocationName ?? "", for: selectedLocation,
                radius: radius,
                identifier: "Geofence-\(selectedLocation.latitude)-\(selectedLocation.longitude)",
                coordinates: selectedLocation
            )
        }
    }
    
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
