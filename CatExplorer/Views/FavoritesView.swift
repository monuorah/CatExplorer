//
//  FavoritesView.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation
import SwiftUI


struct FavoritesView: View {
    @State private var allBreeds: [BreedRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(FavoritesStore.self) private var favoritesStore
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if favoriteBreeds.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadBreeds()
            }
        }
    }
    
    private var favoritesListView: some View {
        List {
            ForEach(favoriteBreeds) { breed in
                NavigationLink(destination: DetailView(breed: breed)) {
                    HStack(spacing: 15) {
                        AsyncImage(url: breed.referenceImageId != nil ? URL(string: "https://cdn2.thecatapi.com/images/\(breed.referenceImageId!).jpg") : nil) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        Text(breed.name)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Search for breeds in the Explore tab and tap the heart icon to add them to your favorites")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading favorites...")
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task {
                    await loadBreeds()
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    
    private var favoriteBreeds: [BreedRecord] {
        return favoritesStore.getFavoriteBreeds(from: allBreeds)
    }
    
    
    private func loadBreeds() async {
        isLoading = true
        errorMessage = nil
        
        do {
            allBreeds = try await CatAPIService.shared.fetchAllBreeds()
            isLoading = false
        } catch {
            errorMessage = "Failed to load breeds: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

#Preview {
    FavoritesView()
        .environment(FavoritesStore())
}
