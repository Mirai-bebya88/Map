//
//  CountriesAPIManager.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import Foundation

protocol CountriesAPIManagerProtocol {
    func fetchCountries(completion: @escaping (Result<[Country], Error>) -> ())
    func fetchCountryByName(name: String, completion: @escaping (Result<Country, Error>) -> Void)
}
    
class CountriesAPIManager: CountriesAPIManagerProtocol {
        func fetchCountries(completion: @escaping (Result<[Country], Error>) -> ()) {
            NetworkManager.shared.get(
                urlString: "https://restcountries.com/v3.1/independent?status=true",
                completion: completion
        )
    }
    
    func fetchCountryByName(name: String, completion: @escaping (Result<Country, Error>) -> Void) {
        
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        let urlString = "https://restcountries.com/v3.1/name/\(encodedName)"
         
        NetworkManager.shared.get(urlString: urlString) { (result: Result<[Country], Error>) in
            switch result {
            case .success(let countries):
                if let country = countries.first {
                    completion(.success(country))
                } else {
                    completion(.failure(NSError(domain: "Country not found", code: 404)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    
    
}
