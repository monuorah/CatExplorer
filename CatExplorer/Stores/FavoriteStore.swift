//
//  FavoriteStore.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation
import SwiftUI

@Observable
class FavoritesStore {
    private(set) var favoriteIDs: Set<String> = []
    
    private let userDefaultsKey = "FavoriteBreedIDs"
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(id: String) -> Bool {
        return favoriteIDs.contains(id)
    }
    
    func toggleFavorite(_ breed: BreedRecord) {
        if favoriteIDs.contains(breed.id) {
            favoriteIDs.remove(breed.id)
        } else {
            favoriteIDs.insert(breed.id)
        }
        saveFavorites()
    }
    
    func getFavoriteBreeds(from allBreeds: [BreedRecord]) -> [BreedRecord] {
        return allBreeds.filter { favoriteIDs.contains($0.id) }
    }
    
    private func saveFavorites() {
        let idsArray = Array(favoriteIDs)
        UserDefaults.standard.set(idsArray, forKey: userDefaultsKey)
    }
    
    private func loadFavorites() {
        if let savedIDs = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            favoriteIDs = Set(savedIDs)
        }
    }
}
