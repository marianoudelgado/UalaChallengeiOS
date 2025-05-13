//
//  CityInfoSheetView.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//


import SwiftUI
import MapKit

struct CityInfoSheetView: View {
    let city: City
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        DetailItemView(iconName: "building.2.fill", label: "Ciudad", value: city.name)
                        DetailItemView(iconName: "flag.fill", label: "País", value: city.country) //
                        DetailItemView(iconName: "number.circle.fill", label: "ID", value: "\(city.id)")
                        DetailItemView(iconName: "arrow.up.arrow.down.circle.fill", label: "Latitud", value: String(format: "%.6f", city.coord.lat))
                        DetailItemView(iconName: "arrow.left.arrow.right.circle.fill", label: "Longitud", value: String(format: "%.6f", city.coord.lon))
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text("Ubicación en el Mapa")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        MapView(coordinate: CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon), cityName: city.name)
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(radius: 3)
                    }
                    .padding(.bottom)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                .navigationTitle(city.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hecho") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

struct CityInfoSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCity = City(country: "US", name: "New York", _id: 5128581, coord: Coordinate(lon: -74.005966, lat: 40.714272))
        CityInfoSheetView(city: sampleCity)
            .preferredColorScheme(.light)
        
        CityInfoSheetView(city: sampleCity)
            .preferredColorScheme(.dark)
    }
}
