//
//  OptimizedPrefixSearchServiceTests.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 12/05/2025.
//


import XCTest
@testable import UalaChallengeiOS

final class OptimizedPrefixSearchServiceTests: XCTestCase {

    var searchService: OptimizedPrefixSearchService!
    var sampleCities: [City]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        searchService = OptimizedPrefixSearchService()

        let citiesRaw = [
            City(country: "US", name: "Alabama", _id: 1, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "US", name: "Albuquerque", _id: 2, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "US", name: "Anaheim", _id: 3, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "US", name: "Arizona", _id: 4, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "AU", name: "Sydney", _id: 5, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "AR", name: "Córdoba", _id: 6, coord: Coordinate(lon: 0, lat: 0)),
            City(country: "AR", name: "Corrientes", _id: 7, coord: Coordinate(lon: 0, lat: 0)),
        ]

        sampleCities = citiesRaw.sorted { city1, city2 in
            return city1.sortKey.compare(city2.sortKey, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) == .orderedAscending
        }
    }

    override func tearDownWithError() throws {
        searchService = nil
        sampleCities = nil
        try super.tearDownWithError()
    }

    func testSearch_withEmptyPrefix_shouldReturnAllCities() {
        let prefix = ""
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertEqual(results.count, sampleCities.count, "Con prefijo vacío, debería devolver todas las ciudades.")
    }

    func testSearch_withSimplePrefix_shouldReturnMatchingCities() {
        let prefix = "a"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertEqual(results.count, 4, "Debería encontrar 4 ciudades que empiezan con 'a'")
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().range(of: prefix, options: [.anchored, .caseInsensitive, .diacriticInsensitive]) != nil })
        XCTAssertEqual(results.map { $0.name }, ["Alabama", "Albuquerque", "Anaheim", "Arizona"])
    }

    func testSearch_withLongerPrefix_shouldReturnMatchingCities() {
        let prefix = "alb"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertEqual(results.count, 1, "Debería encontrar 1 ciudad que empieza con 'alb'")
        XCTAssertEqual(results.first?.name, "Albuquerque")
    }
    
    func testSearch_withPrefixMatchingMultipleCountries_shouldReturnAllMatches() {
        let prefix = "cor"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertEqual(results.count, 2, "Debería encontrar 2 ciudades que empiezan con 'cor'")
        XCTAssertEqual(results.map { $0.name }, ["Córdoba", "Corrientes"], "El orden debería ser Córdoba, luego Corrientes.")
    }

    func testSearch_withCaseInsensitivePrefix_shouldReturnMatchingCities() {
        let prefix = "s"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertEqual(results.count, 1, "Debería encontrar 1 ciudad que empieza con 's'")
        XCTAssertEqual(results.first?.name, "Sydney")
    }

    func testSearch_withNonMatchingPrefix_shouldReturnEmpty() {
        let prefix = "xyz"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertTrue(results.isEmpty, "No debería encontrar ciudades que empiecen con 'xyz'")
    }
    
    func testSearch_withPrefixMatchingEndOfName_shouldNotReturnMatch() {
        let prefix = "que"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertTrue(results.isEmpty, "No debería encontrar 'Albuquerque' buscando por 'que' como prefijo del nombre")
    }
    
    func testSearch_withSpecialCharactersPrefix_shouldReturnEmptyOrHandleGracefully() {
        let prefix = "!@#"
        let results = searchService.search(cities: sampleCities, byPrefixLowercased: prefix)
        XCTAssertTrue(results.isEmpty, "No debería encontrar coincidencias para '!@#'")
    }
}
