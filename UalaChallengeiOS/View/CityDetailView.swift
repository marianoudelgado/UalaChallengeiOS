//
//  CityDetailView.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import SwiftUI
import MapKit

struct CityDetailView: View {
    let city: City

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MapView(coordinate: CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon),
                        cityName: city.name)
                    .frame(height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                VStack(alignment: .leading, spacing: 18) {
                    Text(city.displayName)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .padding(.bottom, 4)

                    VStack(alignment: .leading, spacing: 12) {
                        DetailItemView(iconName: "mappin.and.ellipse", label: "Ubicación", value: "\(city.name), \(city.country)")
                        DetailItemView(iconName: "number.circle", label: "ID", value: "\(city.id)")
                        DetailItemView(iconName: "globe.americas.fill", label: "País", value: city.country)
                        DetailItemView(iconName: "location.fill", label: "Latitud", value: String(format: "%.6f", city.coord.lat))
                        DetailItemView(iconName: "location.fill", label: "Longitud", value: String(format: "%.6f", city.coord.lon))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(city.name)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct DetailItemView: View {
    let iconName: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(.accentColor)
                .frame(width: 25, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

struct CityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCity = City(country: "AR", name: "Córdoba", _id: 987, coord: Coordinate(lon: -64.1888, lat: -31.4201))
        NavigationView {
            CityDetailView(city: sampleCity)
        }
        .previewDisplayName("Light Mode")

        NavigationView {
            CityDetailView(city: sampleCity)
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
