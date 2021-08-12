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
                
                Image(uiImage: movie.image!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
                VStack {
                    
                    Text(movie.title)
                    
                    Text("\(movie.year)")
                    
                }
                
            }
            
        }
        .task {
            let getMovies = await MovieService().getMovie()
            let models = await MovieService().getPosters(from: try! getMovies.get())
            self.movies = try! models.get()
            print(self.movies.count)
        }
        
    }
    
}

@available(macOS 12.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
