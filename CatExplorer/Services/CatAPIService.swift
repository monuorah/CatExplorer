//
//  CatAPIService.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation

class CatAPIService {
    static let shared = CatAPIService()
    
    private let baseURL = "https://api.thecatapi.com/v1"
    
    private init() {}
    
    func fetchAllBreeds() async throws -> [BreedRecord] {
        let urlString = "\(baseURL)/breeds"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let breeds = try decoder.decode([BreedRecord].self, from: data)
        
        return breeds
    }
    
    func fetchBreedImageURL(imageId: String) async throws -> String? {
        let urlString = "\(baseURL)/images/\(imageId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct ImageDetail: Codable {
            let url: String
        }
        
        let decoder = JSONDecoder()
        let imageDetail = try decoder.decode(ImageDetail.self, from: data)
        
        return imageDetail.url
    }
}
