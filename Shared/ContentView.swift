//
//  ContentView.swift
//  Shared
//
//  Created by Michael Craun on 8/11/21.
//

import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    
    @State private var movies: [MovieViewModel] = []
    
    var body: some View {
        
        List(movies, id: \.id) { movie in
            
            HStack {
                
                Image(uiImage: movie.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
                VStack {
                    
                    HStack {
                     
                        Text(movie.title)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Spacer()
                        
                    }
                    
                    HStack {
                        
                        Text("\(movie.year)")
                            .font(.caption)
                        
                        Spacer()
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .refreshable {
            await updateMovieList()
        }
        .task {
            await updateMovieList()
        }
        
    }
    
    private func updateMovieList() async {
        print(#"Fetching movie list for "game of thr"..."#)
        let searchResults = try? await MovieService().search(query: "game+of+thr").get()
        print("Movie list fetched! Fetching posters...")
        for searchResult in (searchResults ?? []) {
            if let modelResult = try? await MovieService().getPoster(for: searchResult).get() {
                print("Poster fetched for \(modelResult.id)...")
                if !movies.contains(where: { $0.id == modelResult.id }) {
                    movies.append(modelResult)
                    print("Posters for \(movies.count) movies fetched so far...")
                }
            }
        }
        print("Finished fetching posters. Enjoy!")
    }
    
}

@available(macOS 12.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
