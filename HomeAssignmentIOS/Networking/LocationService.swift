import Foundation
import CoreLocation

struct NominatimPlace: Codable {
    let place_id: Int
    let display_name: String
    let lat: String
    let lon: String
}

class LocationService {
    func fetchLocations(completion: @escaping (Result<[Location], Error>) -> Void) {
        guard let url = URL(string: "https://raw.githubusercontent.com/Aqib114/locations/refs/heads/main/locations.json")
        
        else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let locations = try JSONDecoder().decode([Location].self, from: data)
                completion(.success(locations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
