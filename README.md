# 🗺️ HomeAssignment

An iOS SwiftUI demo application showcasing real-time user location tracking and interactive geofencing using native Apple frameworks.

---

## 📌 a. Approach, Third-Party Libraries, and Setup

### 🚀 Approach

- Built using **SwiftUI** following **MVVM** architecture principles for clean code separation.
- Utilizes `MapKit` and `CoreLocation` to:
  - Display user’s real-time location on a map.
  - Allow users to select custom geofence areas using map pins and radius controls.
- Custom UI overlays (e.g., geofence radius) implemented in **pure SwiftUI**, with minimal use of `UIKit` (only for action sheets).
- Geofencing is simulated visually using SwiftUI's `Circle`, while logic is handled via a centralized `GeofenceManager`.

### 📦 Third-Party Libraries

- **None** — Entirely implemented using native iOS frameworks:
  - `MapKit`
  - `CoreLocation`
  - `SwiftUI`
  - `UIKit` (for alert presentation only)

### ⚙️ Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/Aqib114/HomeAssignment.git
   ```

2. Open the project in Xcode:
   ```bash
   open HomeAssignment.xcodeproj
   ```

3. Ensure the following keys are added to `Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show it on the map.</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>We use your location to track geofence regions.</string>
   ```

4. Run on a real device or simulate location in the iOS Simulator.

---

## ⚖️ b. Trade-offs and Assumptions

- **UIKit's `UIAlertController`** is used for geofence radius selection due to `SwiftUI`'s limitations with action sheets inside `Map`.
- The geofence radius is rendered using a **SwiftUI overlay**, not `MKOverlay`, to retain full SwiftUI compatibility.
- No persistent storage or background location tracking — the geofence resets when the app restarts.
- Assumes users grant **location permissions**; limited behavior is expected if denied.

---
