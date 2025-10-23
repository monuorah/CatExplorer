//
//  ExploreView.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import Foundation
import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var allBreeds: [BreedRecord] = []
    @State private var selectedBreed: BreedRecord?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(FavoritesStore.self) private var favoritesStore
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if searchText.isEmpty && selectedBreed == nil {
                    placeholderView
                } else if !searchText.isEmpty && suggestions.isEmpty {
                    noResultsView
                } else {
                    contentView
                }
            }
            .navigationTitle("Explore Cats")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadBreeds()
            }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Type a breed (e.g., Aegean)", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        selectedBreed = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: {
                selectRandomBreed()
            }) {
                Image(systemName: "dice")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(eligibleBreedsForRandom.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(eligibleBreedsForRandom.isEmpty)
        }
        .padding()
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !searchText.isEmpty && selectedBreed == nil {
                    suggestionsSection
                }
                
                if let breed = selectedBreed {
                    inlineDetailSection(breed: breed)
                }
            }
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Suggestions")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 10)
            
            ForEach(suggestions) { breed in
                Button(action: {
                    selectBreed(breed)
                }) {
                    HStack {
                        Text(breed.name)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
                .buttonStyle(.plain)
                
                Divider()
            }
        }
    }
    
    private func inlineDetailSection(breed: BreedRecord) -> some View {
        VStack(spacing: 0) {
            DetailView(breed: breed, showNavigationTitle: false)
            
            Spacer()
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Search a breed above")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("or")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("Tap Random")
                .font(.title3)
                .foregroundColor(.blue)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No breeds found")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Try a different search term")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading breeds...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
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
            
            Spacer()
        }
    }
    
    private var suggestions: [BreedRecord] {
        guard !searchText.isEmpty else { return [] }
        
        let query = searchText.lowercased()
        
        let prefixMatches = allBreeds.filter { $0.name.lowercased().hasPrefix(query) }
        let containsMatches = allBreeds.filter {
            !$0.name.lowercased().hasPrefix(query) && $0.name.lowercased().contains(query)
        }
        
        let combined = prefixMatches + containsMatches
        return Array(combined.prefix(3))
    }
    
    private var eligibleBreedsForRandom: [BreedRecord] {
        return allBreeds.filter { $0.isEligibleForRandom }
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
    
    private func selectBreed(_ breed: BreedRecord) {
        selectedBreed = breed
        searchText = breed.name
    }
    
    private func selectRandomBreed() {
        guard let randomBreed = eligibleBreedsForRandom.randomElement() else {
            return
        }
        selectBreed(randomBreed)
    }
}

#Preview {
    ExploreView()
        .environment(FavoritesStore())
}
