//
//  UserDefaultsFavoritesServiceTests.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 12/05/2025.
//


import XCTest
@testable import UalaChallengeiOS

final class UserDefaultsFavoritesServiceTests: XCTestCase {

    var favoritesService: UserDefaultsFavoritesService!
    var testUserDefaults: UserDefaults!
    let suiteName = "TestFavorites_UserDefaultsFavoritesServiceTests"

    override func setUpWithError() throws {
        try super.setUpWithError()
        testUserDefaults = UserDefaults(suiteName: suiteName)
        testUserDefaults?.removePersistentDomain(forName: suiteName)
        let didSynchronizeRemove = testUserDefaults?.synchronize()
        favoritesService = UserDefaultsFavoritesService(userDefaults: testUserDefaults)
    }

    override func tearDownWithError() throws {
        testUserDefaults?.removePersistentDomain(forName: suiteName)
        let didSynchronizeClear = testUserDefaults?.synchronize()
        testUserDefaults = nil
        favoritesService = nil
        try super.tearDownWithError()
    }

    func testLoadFavorites_whenNoFavoritesSaved_shouldReturnEmptySet() {
        print("DEBUG Test: Running testLoadFavorites_whenNoFavoritesSaved_shouldReturnEmptySet")
        let loadedFavorites = favoritesService.loadFavorites()
        XCTAssertTrue(loadedFavorites.isEmpty, "Debería devolver un conjunto vacío si no hay nada guardado. Encontró: \(loadedFavorites)")
    }

    func testSaveFavorites_andLoadFavorites_shouldReturnSavedSet() {
        print("DEBUG Test: Running testSaveFavorites_andLoadFavorites_shouldReturnSavedSet")
        let favoritesToSave: Set<Int> = [1, 5, 100]
        favoritesService.saveFavorites(favoritesToSave)
        let didSynchronizeSave = testUserDefaults.synchronize()
        let loadedFavorites = favoritesService.loadFavorites()
        XCTAssertEqual(loadedFavorites, favoritesToSave, "El conjunto cargado debería ser igual al guardado.")
    }

    func testSaveFavorites_withEmptySet_shouldSaveAndLoadEmptySet() {
        print("DEBUG Test: Running testSaveFavorites_withEmptySet_shouldSaveAndLoadEmptySet")
        let emptyFavorites: Set<Int> = []
        favoritesService.saveFavorites(emptyFavorites)
        testUserDefaults.synchronize()
        let loadedFavorites = favoritesService.loadFavorites()
        XCTAssertTrue(loadedFavorites.isEmpty, "Debería poder guardar y cargar un conjunto vacío.")
    }
    
    func testSaveFavorites_overwritingExisting_shouldSaveAndLoadNewSet() {
        print("DEBUG Test: Running testSaveFavorites_overwritingExisting_shouldSaveAndLoadNewSet")
        let initialFavorites: Set<Int> = [1, 2]
        let newFavorites: Set<Int> = [3, 4, 5]
        favoritesService.saveFavorites(initialFavorites)
        testUserDefaults.synchronize()
        favoritesService.saveFavorites(newFavorites)
        testUserDefaults.synchronize()
        let loadedFavorites = favoritesService.loadFavorites()
        XCTAssertEqual(loadedFavorites, newFavorites, "Debería cargar el último conjunto guardado.")
    }

    func testLoadFavorites_whenSavedDataIsWrongType_shouldReturnEmptySet() {
        print("DEBUG Test: Running testLoadFavorites_whenSavedDataIsWrongType_shouldReturnEmptySet")
        let wrongData = "EstoNoEsUnArrayDeInts"
        testUserDefaults.set(wrongData, forKey: favoritesService.getFavoritesKey())
        testUserDefaults.synchronize() // Sincronizar
        let loadedFavorites = favoritesService.loadFavorites()
        XCTAssertTrue(loadedFavorites.isEmpty, "Debería devolver un conjunto vacío si el tipo de dato guardado es incorrecto.")
    }
}

