//
//  ContentView.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 09/05/2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var citiesViewModel = CitiesViewModel()
    @State private var selectedCityID: City.ID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            CitiesListView(viewModel: citiesViewModel, selectedCityID: $selectedCityID)
        } detail: {
            if let cityID = selectedCityID,
               let city = citiesViewModel.allCities.first(where: { $0.id == cityID }) {
                CityDetailView(city: city)
                    .id(cityID)
            } else {
                VStack {
                    Spacer()
                    Text("Selecciona una ciudad para ver los detalles y el mapa.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

