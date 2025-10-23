//
//  BreedRecord.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation

struct BreedRecord: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let image: BreedImage?
    
    var imageURL: URL? {
        guard let urlString = image?.url else {return nil}
        return URL(string: urlString)
    }
    
    var isEligibleForRandom: Bool {
            return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !description.trimmingCharacters(in: .whitespaces).isEmpty
        }

}

struct BreedImage: Codable, Hashable {
    let url: String
}
