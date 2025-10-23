//
//  ContentView.swift
//  CatExplorer
//
//  Created by Muna Onuorah on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var favoritesStore = FavoritesStore()
    
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
        .environment(favoritesStore)
    }
}

#Preview {
    ContentView()
}
