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
    
    func fetchBreedImage(breedId: String) async throws -> URL? {
        let urlString = "\(baseURL)/images/search?breed_ids=\(breedId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct ImageResult: Codable {
            let url: String
        }
        
        let decoder = JSONDecoder()
        let images = try decoder.decode([ImageResult].self, from: data)
        
        guard let firstImage = images.first else {
            return nil
        }
        
        return URL(string: firstImage.url)
    }
}
