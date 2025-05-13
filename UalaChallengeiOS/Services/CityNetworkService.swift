//
//  CityNetworkService.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 11/05/2025.
//

import Foundation
import Combine

protocol CityFetchingService {
    func fetchCities() -> AnyPublisher<[City], Error>
}

class CityNetworkService: CityFetchingService {

    init() {}

    func fetchCities() -> AnyPublisher<[City], Error> {
        guard let url = Constants.citiesDataURL else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        if let errorBody = String(data: data, encoding: .utf8) {
                            print("DEBUG NetworkService: Cuerpo del error del servidor: \(errorBody)")
                        }
                        throw URLError(URLError.Code(rawValue: httpResponse.statusCode),
                                       userInfo: [NSLocalizedDescriptionKey: "Respuesta no exitosa del servidor: \(httpResponse.statusCode)"])
                    }
                } else {
                    print("DEBUG NetworkService: La respuesta no es HTTPURLResponse. Tipo de respuesta: \(type(of: response))")
                    throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "La respuesta del servidor no fue una respuesta HTTP."])
                }
                return data
            }
            .decode(type: [City].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
