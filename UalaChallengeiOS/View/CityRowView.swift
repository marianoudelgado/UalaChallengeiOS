//
//  CityRowView.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//

import SwiftUI

struct CityRowView: View {
    let city: City
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onShowInfo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
           
                    .accessibilityIdentifier("cityDisplayName_\(city.id)")
                Text("Coords: \(String(format: "%.4f", city.coord.lat)), \(String(format: "%.4f", city.coord.lon))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                Button(action: onShowInfo) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("infoButton_\(city.id)")

                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("favoriteButton_\(city.id)")
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("cityRow_\(city.id)")
    }
}

struct CityRowView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCity = City(country: "AR", name: "Cordoba", _id: 123, coord: Coordinate(lon: -58.3816, lat: -34.6037))
        List {
            CityRowView(city: sampleCity, isFavorite: true, onToggleFavorite: {}, onShowInfo: {})
            CityRowView(city: sampleCity, isFavorite: false, onToggleFavorite: {}, onShowInfo: {})
        }
    }
}
