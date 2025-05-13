//
//  CityModels.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 09/05/2025.
//


import Foundation

struct Coordinate: Codable, Hashable {
    let lon: Double
    let lat: Double
}

struct City: Codable, Identifiable, Hashable {
    let country: String
    let name: String
    let _id: Int
    let coord: Coordinate

    var id: Int { return _id }

    var displayName: String { "\(name), \(country)" }
    var sortKey: String { return "\(name.lowercased()), \(country.lowercased())" }
}
