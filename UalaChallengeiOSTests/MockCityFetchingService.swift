//
//  MockCityFetchingService.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 12/05/2025.
//

import XCTest
import Combine
@testable import UalaChallengeiOS

class MockCityFetchingService: CityFetchingService {
    var fetchCitiesResult: Result<[City], Error> = .success([])
    var fetchCitiesCallCount = 0 // Contador de llamadas
    private var citiesSubject: PassthroughSubject<[City], Error>?

    func fetchCities() -> AnyPublisher<[City], Error> {
        fetchCitiesCallCount += 1
        let subject = PassthroughSubject<[City], Error>()
        citiesSubject = subject
        return subject.eraseToAnyPublisher()
    }
    
    func completeFetch(with result: Result<[City], Error>) {
        switch result {
        case .success(let cities):
            citiesSubject?.send(cities)
            citiesSubject?.send(completion: .finished)
        case .failure(let error):
            citiesSubject?.send(completion: .failure(error))
        }
    }
}

class MockFavoritesPersistenceService: FavoritesPersistenceServicing {
    var savedFavoritesSet: Set<Int>?
    var loadedFavoritesSet: Set<Int> = []
    var saveFavoritesCallCount = 0
    var loadFavoritesCallCount = 0

    func saveFavorites(_ favoriteIDs: Set<Int>) {
        saveFavoritesCallCount += 1
        savedFavoritesSet = favoriteIDs
    }

    func loadFavorites() -> Set<Int> {
        loadFavoritesCallCount += 1
        return loadedFavoritesSet
    }

    func getFavoritesKey() -> String {
        return "mockFavoritesKey_for_ViewModelTests"
    }
}

class MockCitySearchService: CitySearchPerforming {
    var searchResultToReturn: [City] = []
    var searchCallCount = 0
    var lastSearchedPrefix: String?
    var lastCitiesInput: [City]?

    func search(cities: [City], byPrefixLowercased prefix: String) -> [City] {
        searchCallCount += 1
        lastSearchedPrefix = prefix
        lastCitiesInput = cities
        return searchResultToReturn
    }
}

final class CitiesViewModelTests: XCTestCase {
    var viewModel: CitiesViewModel!
    var mockFetcher: MockCityFetchingService!
    var mockPersister: MockFavoritesPersistenceService!
    var mockSearcher: MockCitySearchService!
    var cancellables: Set<AnyCancellable>!
    
    let cityNY = City(country: "US", name: "New York", _id: 1, coord: Coordinate(lon: -74.0060, lat: 40.7128))
    let cityCordobaAR = City(country: "AR", name: "Córdoba", _id: 2, coord: Coordinate(lon: -64.1888, lat: -31.4201))
    let cityCorrientesAR = City(country: "AR", name: "Corrientes", _id: 3, coord: Coordinate(lon: -58.8306, lat: -27.4692))
    let cityNewarkUS = City(country: "US", name: "Newark", _id: 4, coord: Coordinate(lon: -74.1724, lat: 40.7357))
    
    var allSampleCitiesSorted: [City]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockFetcher = MockCityFetchingService()
        mockPersister = MockFavoritesPersistenceService()
        mockSearcher = MockCitySearchService()
        cancellables = Set<AnyCancellable>()

        allSampleCitiesSorted = [cityNY, cityCordobaAR, cityCorrientesAR, cityNewarkUS].sorted { $0.sortKey < $1.sortKey }

        viewModel = CitiesViewModel(
            cityFetchingService: mockFetcher,
            favoritesPersistenceService: mockPersister,
            searchService: mockSearcher
        )
        
        viewModel.allCities = allSampleCitiesSorted
        viewModel.applyFilters()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockFetcher = nil
        mockPersister = nil
        mockSearcher = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testInit_shouldLoadFavoritesFromPersistence() {
        XCTAssertEqual(mockPersister.loadFavoritesCallCount, 1, "loadFavorites() debería llamarse exactamente una vez durante la inicialización del ViewModel.")
        XCTAssertTrue(viewModel.favoriteCityIDs.isEmpty, "Inicialmente, favoriteCityIDs debería estar vacío si el mock devuelve vacío.")
    }

    func testFetchAndPrepareCities_onSuccess_shouldUpdatePropertiesAndSortCities() {
        let expectation = XCTestExpectation(description: "El ViewModel actualiza sus propiedades correctamente tras un fetch exitoso.")
        
        let unsortedCitiesToFetch = [cityCordobaAR, cityNewarkUS, cityNY]
        let expectedSortedCityIDs = unsortedCitiesToFetch.sorted { $0.sortKey < $1.sortKey }.map { $0.id }

        viewModel.allCities = []
        
        var isLoadingSequence: [Bool] = []
        viewModel.$isLoading
            .sink { isLoadingValue in
                isLoadingSequence.append(isLoadingValue)
                if isLoadingSequence == [false, true, false] {
                    DispatchQueue.main.async {
                        XCTAssertNil(self.viewModel.errorMessage, "No debería haber mensaje de error en un fetch exitoso.")
                        XCTAssertEqual(self.viewModel.allCities.map { $0.id }, expectedSortedCityIDs, "allCities debería contener las ciudades fetcheadas y ordenadas por sortKey.")
                        XCTAssertEqual(self.viewModel.displayedCities.map { $0.id }, expectedSortedCityIDs, "displayedCities inicialmente debería mostrar todas las ciudades ordenadas.")
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.fetchAndPrepareCities()
        mockFetcher.completeFetch(with: .success(unsortedCitiesToFetch))

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchAndPrepareCities_onFailure_shouldSetErrorMessageAndClearCities() {
        let expectation = XCTestExpectation(description: "El ViewModel maneja correctamente un error durante el fetch.")
        let expectedError = URLError(.notConnectedToInternet)

        viewModel.allCities = allSampleCitiesSorted
        viewModel.displayedCities = allSampleCitiesSorted
        
        var isLoadingSequence: [Bool] = []
        viewModel.$isLoading
            .sink { isLoadingValue in
                isLoadingSequence.append(isLoadingValue)
                 if isLoadingSequence == [false, true, false] {
                    DispatchQueue.main.async {
                        XCTAssertNotNil(self.viewModel.errorMessage, "Debería haber un mensaje de error.")
                        XCTAssertTrue(self.viewModel.errorMessage?.contains("Error al cargar las ciudades") ?? false)
                        XCTAssertTrue(self.viewModel.allCities.isEmpty, "allCities debería estar vacía después de un error de fetch.")
                        XCTAssertTrue(self.viewModel.displayedCities.isEmpty, "displayedCities debería estar vacía después de un error de fetch.")
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
            
        viewModel.fetchAndPrepareCities()
        mockFetcher.completeFetch(with: .failure(expectedError))

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchTextChange_shouldTriggerSearchServiceAndFilterDisplayedCities() {
        let expectation = XCTestExpectation(description: "Cambiar searchText llama al servicio de búsqueda y actualiza displayedCities.")
        
        let searchTextToTest = "cor"
        let expectedSearchResultsFromService = [cityCordobaAR, cityCorrientesAR]
        mockSearcher.searchResultToReturn = expectedSearchResultsFromService

        var fulfilled = false
        viewModel.$displayedCities
            .filter { _ in self.viewModel.searchText == searchTextToTest }
            .sink { currentDisplayedCities in
                if !fulfilled {
                    XCTAssertEqual(self.mockSearcher.searchCallCount, 1, "El método search del servicio de búsqueda debería llamarse una vez.")
                    XCTAssertEqual(self.mockSearcher.lastSearchedPrefix, searchTextToTest.lowercased(), "El prefijo pasado al servicio de búsqueda debería estar en minúsculas.")
                    XCTAssertEqual(currentDisplayedCities.map { $0.id }, expectedSearchResultsFromService.map { $0.id }, "displayedCities debería reflejar el resultado del servicio de búsqueda.")
                    expectation.fulfill()
                    fulfilled = true
                }
            }
            .store(in: &cancellables)

        viewModel.searchText = searchTextToTest
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testToggleFavorite_shouldUpdateFavoriteSetAndCallPersistenceService() {
        let cityIdToToggle = cityNY.id
        
        XCTAssertFalse(viewModel.favoriteCityIDs.contains(cityIdToToggle), "Inicialmente, la ciudad no debería ser favorita.")

        viewModel.toggleFavorite(for: cityIdToToggle)

        XCTAssertTrue(viewModel.favoriteCityIDs.contains(cityIdToToggle), "La ciudad debería estar en favoritos después del primer toggle.")
        XCTAssertEqual(mockPersister.saveFavoritesCallCount, 1, "saveFavorites() debería llamarse una vez.")
        XCTAssertEqual(mockPersister.savedFavoritesSet, [cityIdToToggle], "El conjunto correcto de favoritos debería pasarse a saveFavorites.")

        viewModel.toggleFavorite(for: cityIdToToggle)

        XCTAssertFalse(viewModel.favoriteCityIDs.contains(cityIdToToggle), "La ciudad no debería estar en favoritos después del segundo toggle.")
        XCTAssertEqual(mockPersister.saveFavoritesCallCount, 2, "saveFavorites() debería llamarse dos veces en total.")
        XCTAssertEqual(mockPersister.savedFavoritesSet, [], "El conjunto vacío de favoritos debería pasarse a saveFavorites.")
    }
    
    func testUpdateFilterSettings_whenShowOnlyFavoritesActivated_shouldFilterDisplayedCities() {
        viewModel.favoriteCityIDs = [cityCordobaAR.id]
        viewModel.applyFilters()
        
        XCTAssertEqual(viewModel.displayedCities.count, allSampleCitiesSorted.count, "Inicialmente, todas las ciudades deberían mostrarse.")

        viewModel.updateFilterSettings(showOnlyFavorites: true)

        XCTAssertTrue(viewModel.showOnlyFavoritesActive, "showOnlyFavoritesActive debería ser true.")
        XCTAssertEqual(viewModel.displayedCities.count, 1, "Solo debería mostrarse 1 ciudad favorita.")
        XCTAssertEqual(viewModel.displayedCities.first?.id, cityCordobaAR.id, "La ciudad mostrada debería ser Córdoba AR.")
        
        viewModel.updateFilterSettings(showOnlyFavorites: false)
        
        XCTAssertFalse(viewModel.showOnlyFavoritesActive, "showOnlyFavoritesActive debería ser false.")
        XCTAssertEqual(viewModel.displayedCities.count, allSampleCitiesSorted.count, "Todas las ciudades deberían mostrarse de nuevo.")
    }

    func testApplyFilters_withSearchTextAndFavoritesActive_shouldShowOnlyMatchingFavorites() {
        let expectation = XCTestExpectation(description: "Filtra por texto y luego por favoritos")
        
        viewModel.favoriteCityIDs = [cityNY.id]
        mockSearcher.searchResultToReturn = [cityNY, cityNewarkUS]

        viewModel.updateFilterSettings(showOnlyFavorites: true)
        
        var fulfilled = false
        viewModel.$displayedCities
            .filter { _ in self.viewModel.searchText == "new" }
            .sink { displayedCities in
                if !fulfilled {
                    print("DEBUG Test: Sink para 'new' activado. DisplayedCities count: \(displayedCities.count)")
                    XCTAssertTrue(self.viewModel.showOnlyFavoritesActive, "El filtro de favoritos debería estar activo.")
                    XCTAssertEqual(displayedCities.count, 1, "Solo debería mostrar New York (favorita y coincide con 'new').")
                    XCTAssertEqual(displayedCities.first?.id, self.cityNY.id, "La ciudad mostrada debería ser New York.")
                    XCTAssertGreaterThanOrEqual(self.mockSearcher.searchCallCount, 1, "El servicio de búsqueda debió llamarse al menos una vez para 'new'.")
                    expectation.fulfill()
                    fulfilled = true
                }
            }
            .store(in: &cancellables)

        viewModel.searchText = "new"
    
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testToggleFavorite_whenShowOnlyFavoritesIsActive_shouldCorrectlyUpdateDisplayedCities() {
        viewModel.favoriteCityIDs = [cityCordobaAR.id]
        viewModel.updateFilterSettings(showOnlyFavorites: true)
        
        XCTAssertEqual(viewModel.displayedCities.map { $0.id }, [cityCordobaAR.id], "Inicialmente, solo Córdoba AR debería estar en displayedCities.")

        viewModel.toggleFavorite(for: cityCordobaAR.id)

        XCTAssertTrue(viewModel.displayedCities.isEmpty, "displayedCities debería estar vacía después de quitar el único favorito visible.")
        XCTAssertFalse(viewModel.favoriteCityIDs.contains(cityCordobaAR.id), "Córdoba AR ya no debería ser favorita.")

        viewModel.toggleFavorite(for: cityCordobaAR.id)
        
        XCTAssertEqual(viewModel.displayedCities.map { $0.id }, [cityCordobaAR.id], "displayedCities debería mostrar Córdoba AR de nuevo.")
        XCTAssertTrue(viewModel.favoriteCityIDs.contains(cityCordobaAR.id), "Córdoba AR debería ser favorita de nuevo.")
    }
}
