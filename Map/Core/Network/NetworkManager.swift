//
//  NetworkManager.swift
//  Map
//
//  Created by elene malakmadze on 29.12.25.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func get<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
