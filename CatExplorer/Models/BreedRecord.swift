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
    let referenceImageId: String?
    
    var imageURL: URL? {
        guard let imageId = referenceImageId else {return nil}
        return URL(string: "https://cdn2.thecatapi.com/images/\(imageId).jpg")
    }
    
    var isEligibleForRandom: Bool {
            return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !description.trimmingCharacters(in: .whitespaces).isEmpty
        }
        
        enum CodingKeys: String, CodingKey {
            case id, name, description
            case referenceImageId = "reference_image_id"
        }
}
