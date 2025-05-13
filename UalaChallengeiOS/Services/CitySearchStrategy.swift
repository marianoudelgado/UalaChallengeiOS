//
//  CitySearchStrategy.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import Foundation

protocol CitySearchPerforming {
    func search(cities: [City], byPrefixLowercased prefix: String) -> [City]
}

class OptimizedPrefixSearchService: CitySearchPerforming {
    private func findLowerBoundIndex(in cities: [City], forSortKeyPrefix prefix: String) -> Int {
        var low = 0
        var high = cities.count
        while low < high {
            let mid = low + (high - low) / 2
            if cities[mid].sortKey < prefix {
                low = mid + 1
            } else {
                high = mid
            }
        }
        return low
    }

    func search(cities: [City], byPrefixLowercased prefix: String) -> [City] {
        guard !prefix.isEmpty else { return cities }

        let startIndex = findLowerBoundIndex(in: cities, forSortKeyPrefix: prefix)
        var results: [City] = []

        for i in startIndex..<cities.count {
            let city = cities[i]
            let cityNameLower = city.name.lowercased()
            let compareOptions: String.CompareOptions = [.anchored, .diacriticInsensitive, .caseInsensitive]

            if cityNameLower.range(of: prefix, options: compareOptions) != nil {
                results.append(city)
            } else {
                if !cities[i].sortKey.hasPrefix(prefix) {
                     break
                }
            }
        }
        return results
    }
}

