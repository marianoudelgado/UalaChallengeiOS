//
//  FavoritesPersistenceServicing.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import Foundation

protocol FavoritesPersistenceServicing {
    func saveFavorites(_ favoriteIDs: Set<Int>)
    func loadFavorites() -> Set<Int>
    func getFavoritesKey() -> String
}

class UserDefaultsFavoritesService: FavoritesPersistenceServicing {

    private let favoritesKey = "userFavoriteCityIDs"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveFavorites(_ favoriteIDs: Set<Int>) {
        let favoritesArray = Array(favoriteIDs)
        userDefaults.set(favoritesArray, forKey: favoritesKey)
    }

    func loadFavorites() -> Set<Int> {
        let objectLoaded = userDefaults.object(forKey: favoritesKey)

        guard let favoritesArray = objectLoaded as? [Int] else {
            if objectLoaded != nil {
                print("DEBUG FavoritesService: Found object for key '\(favoritesKey)', but it's not [Int]. Type: \(type(of: objectLoaded!))")
            } else {
                print("DEBUG FavoritesService: No object found for key '\(favoritesKey)'. Returning empty set.")
            }
            return Set<Int>()
        }
        print("DEBUG FavoritesService: Successfully loaded \(favoritesArray.count) favorite IDs: \(favoritesArray)")
        return Set(favoritesArray)
    }

    public func getFavoritesKey() -> String {
       return favoritesKey
    }
}
