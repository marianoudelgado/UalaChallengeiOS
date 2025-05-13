//
//  CityListView.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import SwiftUI

struct CitiesListView: View {
    @ObservedObject var viewModel: CitiesViewModel
    @Binding var selectedCityID: City.ID?
    @State private var showOnlyFavorites: Bool = false
    @State private var cityForInfoSheet: City? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                TextField("Buscar ciudad por nombre...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Toggle("Mostrar solo favoritos", isOn: $showOnlyFavorites)
                    .padding(.horizontal)
                    .onChange(of: showOnlyFavorites) { _, newValue in
                        viewModel.updateFilterSettings(showOnlyFavorites: newValue)
                    }
            }
            .padding(.vertical, 10)

            ZStack {
                if $viewModel.displayedCities.isEmpty && !viewModel.isLoading {
                    VStack {
                        Spacer()
                        if !viewModel.searchText.isEmpty {
                            ContentUnavailableView( // Requiere iOS 17+
                                "Sin resultados",
                                systemImage: "magnifyingglass",
                                description: Text("No se encontraron ciudades para \"\(viewModel.searchText)\". Intenta con otro término.")
                            )
                        } else if showOnlyFavorites {
                             ContentUnavailableView( // Requiere iOS 17+
                                "Sin Favoritos",
                                systemImage: "star.slash",
                                description: Text("No tienes ciudades marcadas como favoritas. ¡Explora y añade algunas!")
                            )
                        } else if viewModel.errorMessage == nil {
                             ContentUnavailableView(
                                "Lista Vacía",
                                systemImage: "list.bullet.rectangle.portrait",
                                description: Text("Parece que no hay ciudades para mostrar en este momento.")
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                } else {
                    List(selection: $selectedCityID) {
                        ForEach(viewModel.displayedCities) { city in
                            CityRowView(
                                city: city,
                                isFavorite: viewModel.isCityFavorite(cityID: city.id),
                                onToggleFavorite: {
                                    viewModel.toggleFavorite(for: city.id)
                                },
                                onShowInfo: {
                                    self.cityForInfoSheet = city
                                }
                            )
                            .tag(city.id)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                if viewModel.isLoading {
                    ProgressView("Cargando...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                } else if let errorMessage = viewModel.errorMessage {
                     VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(10)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Ciudades")
        .onAppear {
            if $viewModel.allCities.isEmpty && !viewModel.isLoading {
                viewModel.fetchAndPrepareCities()
            }
        }
        .sheet(item: $cityForInfoSheet) { cityItemInSheet in
            NavigationView {
                CityInfoSheetView(city: cityItemInSheet)
            }
        }
    }
}

struct CitiesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
             CitiesListView(
                 viewModel: CitiesViewModel(),
                 selectedCityID: .constant(nil)
             )
        }
    }
}
