//
//  HttpClient.swift
//  JedlixSDK
//
//  Copyright © 2022 Jedlix. All rights reserved.
//

import Foundation
import JedlixSDK

class HTTPClient {
    private struct Path {
        static let base = "/api/v01-01"
        static let vehicles = "/users/%@/vehicles"
        static let vehicle = "/users/%@/vehicles/%@"
        static let chargingLocations = "/users/%@/charging-locations"
        static let chargingLocation = "/users/%@/charging-locations/%@"
        static let chargers = "/users/%@/chargers"
        static let charger = "/users/%@/charging-locations/%@/chargers/%@"
    }
    
    private let userIdentifier: String
    
    required init(userIdentifier: String) {
        self.userIdentifier = userIdentifier
    }
    
    func getVehicles() async throws -> [Vehicle] {
        var request = try await request(with: Path.vehicles, parameters: userIdentifier)
        request.httpMethod = "GET"
        let response = try await URLSession.shared.response(for: request, delegate: nil)
        let data = response.0
        do {
            return try JSONDecoder().decode([Vehicle].self, from: data)
        } catch {
            let errorResponse = try JSONDecoder().decode(HTTPErrorResponse.self, from: data)
            throw HTTPError.errorResponse(detail: errorResponse.detail)
        }
    }
    
    func removeVehicle(_ vehicle: Vehicle) async throws {
        var request = try await request(with: Path.vehicle, parameters: userIdentifier, vehicle.id)
        request.httpMethod = "DELETE"
        let response = try await URLSession.shared.response(for: request, delegate: nil)
        let data = response.0
        let urlResponse = response.1
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else {
            throw try HTTPError(with: data)
        }
    }
    
    func getChargingLocations() async throws -> [ChargingLocation] {
        var request = try await request(with: Path.chargingLocations, parameters: userIdentifier)
        request.httpMethod = "GET"
        let response = try await URLSession.shared.response(for: request, delegate: nil)
        let data = response.0
        do {
            return try JSONDecoder().decode([ChargingLocation].self, from: data)
        } catch {
            let errorResponse = try JSONDecoder().decode(HTTPErrorResponse.self, from: data)
            throw HTTPError.errorResponse(detail: errorResponse.detail)
        }
    }
    
    func getChargers() async throws -> [Charger] {
        var request = try await request(with: Path.chargers, parameters: userIdentifier)
        request.httpMethod = "GET"
        let response = try await URLSession.shared.response(for: request, delegate: nil)
        let data = response.0
        do {
            return try JSONDecoder().decode([Charger].self, from: data)
        } catch {
            let errorResponse = try JSONDecoder().decode(HTTPErrorResponse.self, from: data)
            throw HTTPError.errorResponse(detail: errorResponse.detail)
        }
    }
    
    func removeCharger(_ charger: Charger) async throws {
        var request = try await request(with: Path.charger, parameters: userIdentifier, charger.chargingLocationId, charger.id)
        request.httpMethod = "DELETE"
        let response = try await URLSession.shared.response(for: request, delegate: nil)
        let data = response.0
        let urlResponse = response.1
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else {
            throw try HTTPError(with: data)
        }
    }
    
    private func request(with path: String, parameters: String...) async throws -> URLRequest {
        guard let accessToken = await authentication.getAccessToken() else { throw HTTPError.notAuthenticated }
        let pathWithParameters = String(format: path, arguments: parameters)
        let url = URL(string: baseURL.absoluteString + Path.base + pathWithParameters)!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
