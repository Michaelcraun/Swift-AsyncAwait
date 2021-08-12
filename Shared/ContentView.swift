//
//  ContentView.swift
//  Shared
//
//  Created by Michael Craun on 8/11/21.
//

import SwiftUI

struct ContentView: View {
    
    // MainActor objects MUST be declared as StateObject's
    @StateObject private var viewModel = MovieListViewModel()
    
    var body: some View {
        
        List(viewModel.movies, id: \.id) { movie in
            
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
            await viewModel.getMovies()
        }
        .task {
            await viewModel.getMovies()
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
