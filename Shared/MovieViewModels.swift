//
//  MovieViewModels.swift
//  AsyncAwait
//
//  Created by Michael Craun on 8/12/21.
//

import UIKit

enum MovieError: Error {
    case badURL
}

struct MovieResult: Decodable {
    
    let results: [Movie]
    
}

struct Movie: Decodable {
    
    let id: String
    let image: MovieImage?
    let title: String
    let year: Int
    
}

struct MovieImage: Decodable {
    
    let url: String
    
}

class MovieViewModel {
    
    let movie: Movie
    var id: String { movie.id }
    var imageURL: String? { movie.image?.url }
    var title: String { movie.title }
    var year: Int { movie.year }
    var image: UIImage
    
    init(movie: Movie, image: UIImage = UIImage()) {
        self.image = image
        self.movie = movie
    }
    
}

@MainActor
class MovieListViewModel: ObservableObject {
    
    @Published var movies: [MovieViewModel] = []
    
    func getMovies() async {
        
        print(#"Fetching movie list for "game of thr"..."#)
        let searchResults = try? await MovieService().search(query: "game+of+thr").get()
        print("Movie list fetched! Fetching posters...")
        for searchResult in (searchResults ?? []) {
            if !movies.contains(where: { $0.id == searchResult.id }) {
            if let modelResult = try? await MovieService().getPoster(for: searchResult).get() {
                    print("Poster fetched for \(modelResult.id)...")
                    movies.append(modelResult)
                    print("Posters for \(movies.count) movies fetched so far...")
                    movies = movies.sorted(by: { $0.year >= $1.year })
                }
            } else {
                print("Skipped downloading poster for \(searchResult.id); already fetched!")
            }
        }
        print("Finished fetching posters. Enjoy!")
        
    }
    
}
