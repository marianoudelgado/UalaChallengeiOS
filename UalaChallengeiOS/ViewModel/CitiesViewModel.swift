//
// CitiesViewModel.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import Foundation
import Combine

class CitiesViewModel: ObservableObject {

    // --- Estados Publicados para la UI ---
    @Published var displayedCities: [City] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var favoriteCityIDs: Set<Int> = []
    @Published var showOnlyFavoritesActive: Bool = false

    // --- Propiedades Internas ---
    var allCities: [City] = [] // Pre-ordenada por sortKey
    private var cancellables = Set<AnyCancellable>()

    // --- Dependencias ---
    private let cityFetchingService: CityFetchingService
    private let favoritesPersistenceService: FavoritesPersistenceServicing
    private let searchService: CitySearchPerforming // Para la búsqueda optimizada

    // --- Inicializador ---
    init(
        cityFetchingService: CityFetchingService = CityNetworkService(),
        favoritesPersistenceService: FavoritesPersistenceServicing = UserDefaultsFavoritesService(),
        searchService: CitySearchPerforming = OptimizedPrefixSearchService() // Inyectamos la búsqueda optimizada
    ) {
        self.cityFetchingService = cityFetchingService
        self.favoritesPersistenceService = favoritesPersistenceService
        self.searchService = searchService

        self.loadPersistedFavorites()

        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Debounce para no sobrecargar
            .removeDuplicates() // Solo si el texto cambia
            .sink { [weak self] _ in // El texto ya está en self.searchText
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }

    // --- Métodos de Carga de Datos ---
    func fetchAndPrepareCities() {
        isLoading = true
        errorMessage = nil
        allCities = [] // Limpiamos por si es una recarga
        displayedCities = []

        cityFetchingService.fetchCities()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Error al cargar las ciudades: \(error.localizedDescription)"
                    print("Error fetching cities: \(error)")
                case .finished:
                    print("Ciudades cargadas y procesadas con éxito.")
                    break
                }
            }, receiveValue: { [weak self] fetchedCities in
                guard let self = self else { return }
                // Ordenar las ciudades usando 'sortKey'. Esto es crucial para la búsqueda optimizada.
                // `sortKey` es `nombreCiudad.lowercased(), codigoPais.lowercased()`
                self.allCities = fetchedCities.sorted { $0.sortKey < $1.sortKey }
                self.applyFilters() // Aplicar filtros iniciales
            })
            .store(in: &cancellables)
    }

    // --- Lógica de Filtros ---
    func updateFilterSettings(showOnlyFavorites: Bool) {
        self.showOnlyFavoritesActive = showOnlyFavorites
        applyFilters()
    }

    func applyFilters() {
        var citiesToFilter = allCities // Empezamos con todas las ciudades (ya ordenadas)

        // 1. Filtrar por texto de búsqueda usando el servicio optimizado
        if !searchText.isEmpty {
            let lowercasedSearchText = searchText.lowercased()
            // El servicio de búsqueda espera la lista completa pre-ordenada y el prefijo en minúsculas.
            citiesToFilter = searchService.search(cities: allCities, byPrefixLowercased: lowercasedSearchText)
        }
        // Si searchText está vacío, citiesToFilter sigue siendo allCities.

        // 2. Filtrar por favoritos si el toggle está activo (sobre el resultado de la búsqueda por texto)
        if showOnlyFavoritesActive {
            // Si ya filtramos por texto, aplicamos este filtro al resultado.
            // Si no filtramos por texto, lo aplicamos a allCities (o a lo que sea citiesToFilter en ese punto).
            citiesToFilter = citiesToFilter.filter { city in
                favoriteCityIDs.contains(city.id)
            }
        }
        
        // El resultado de la búsqueda y el filtro de favoritos deben preservar el orden.
        displayedCities = citiesToFilter
    }

    // --- Lógica de Favoritos ---
    func isCityFavorite(cityID: Int) -> Bool {
        return favoriteCityIDs.contains(cityID)
    }

    func toggleFavorite(for cityID: Int) {
        if favoriteCityIDs.contains(cityID) {
            favoriteCityIDs.remove(cityID)
        } else {
            favoriteCityIDs.insert(cityID)
        }
        self.savePersistedFavorites()

        // Re-aplicar filtros si estamos mostrando solo favoritos para reflejar el cambio.
        if showOnlyFavoritesActive {
            applyFilters()
        }
        // Si no estamos mostrando solo favoritos, no es estrictamente necesario re-filtrar aquí,
        // ya que la lista principal no cambiará, solo el estado de la estrella.
        // Pero si la búsqueda por texto estaba activa, y la ciudad recién marcada/desmarcada
        // estaba en los resultados, y 'showOnlyFavoritesActive' es true, entonces sí.
        // La condición actual `if showOnlyFavoritesActive` cubre esto.
    }

    // --- Métodos para Persistencia de Favoritos ---
    private func savePersistedFavorites() {
        favoritesPersistenceService.saveFavorites(favoriteCityIDs)
    }

    private func loadPersistedFavorites() {
        self.favoriteCityIDs = favoritesPersistenceService.loadFavorites()
    }
}
