//
//  DetailView.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation
import SwiftUI

struct DetailView: View {
    let breed: BreedRecord
    @Environment(FavoritesStore.self) private var favoritesStore
    
    let showNavigationTitle: Bool
    
    init(breed: BreedRecord, showNavigationTitle: Bool = true) {
        self.breed = breed
        self.showNavigationTitle = showNavigationTitle
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: breed.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 300)
                            
                            VStack(spacing: 10) {
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Image unavailable")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                
                HStack(alignment: .center) {
                    Text(breed.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        favoritesStore.toggleFavorite(breed)
                    }) {
                        Image(systemName: favoritesStore.isFavorite(id: breed.id) ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(favoritesStore.isFavorite(id: breed.id) ? .red : .gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(breed.description.isEmpty ? "No description available" : breed.description)
                        .font(.body)
                        .foregroundColor(breed.description.isEmpty ? .gray : .primary)
                }
            }
            .padding()
        }
        .navigationTitle(showNavigationTitle ? breed.name : "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetailView(
            breed: BreedRecord(
                id: "abys",
                name: "Abyssinian",
                description: "The Abyssinian is easy to care for and has a lively personality.",
                image: BreedImage(url: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg")
            )
        )
        .environment(FavoritesStore())
    }
}
