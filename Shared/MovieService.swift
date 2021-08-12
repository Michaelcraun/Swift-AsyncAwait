//
//  MovieService.swift
//  AsyncAwait
//
//  Created by Michael Craun on 8/11/21.
//

import UIKit

@available(macOS 12.0, *)
class MovieService {
    
    private let root: String = "https://imdb8.p.rapidapi.com/title/find"
    private var request: URLRequest {
        guard let url = URL(string: "\(root)?q=game+of+thr") else { fatalError() }
        var request = URLRequest(url: url)
        request.addValue("f4416e782dmsha78fe83ba200131p18beeajsnd80827d4325b", forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("imdb8.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"
        return request
    }
    
    func getMovie() async -> Result<[Movie],Error> {
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String : Any]
            let fetched = try JSONSerialization.data(withJSONObject: json["results"] as! [[String : Any]], options: .fragmentsAllowed)
            let results = try JSONDecoder().decode([Movie].self, from: fetched)
            return .success(results)
        } catch {
            print(error)
            return .failure(error)
        }
        
    }
    
    func getPosters(from movies: [Movie]) async -> Result<[MovieViewModel], Error> {
        
        var models: [MovieViewModel] = []
        
        for movie in movies {
            guard let posterURL = movie.image?.url, let url = URL(string: posterURL) else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = UIImage(data: data)
                let model = MovieViewModel.init(movie: movie)
                model.image = image
                models.append(model)
            } catch {
                print(error)
            }
        }
        return .success(models)
        
    }
    
}

enum MovieError: Error {
    case badURL
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
    var image: UIImage?
    
    init(movie: Movie) {
        self.movie = movie
    }
    
}
