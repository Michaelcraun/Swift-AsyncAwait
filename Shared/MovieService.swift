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
    
    private func buildRequest(with parameters: [(key: String, value: String)]) -> URLRequest {
        
        precondition(!parameters.isEmpty)
        
        var urlString = "\(root)?"
        parameters.forEach { urlString += "\($0.key)=\($0.value)" }
        
        guard let url = URL(string: urlString) else { fatalError() }
        var request = URLRequest(url: url)
        request.addValue("f4416e782dmsha78fe83ba200131p18beeajsnd80827d4325b", forHTTPHeaderField: "x-rapidapi-key")
        request.addValue("imdb8.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        request.httpMethod = "GET"
        return request
        
    }
    
    func search(query: String) async -> Result<[Movie],Error> {
        
        do {
            let request = buildRequest(with: [(key: "q", value: query)])
            let (data, response) = try await URLSession.shared.data(for: request)
            if let status = (response as? HTTPURLResponse)?.statusCode, status < 200 || status > 200 { fatalError() }
            let result = try JSONDecoder().decode(MovieResult.self, from: data)
            return .success(result.results)
        } catch {
            print(error)
            return .failure(error)
        }
        
    }
    
    func getPoster(for movie: Movie) async -> Result<MovieViewModel,Error> {
        
        if let posterURL = movie.image?.url, let url = URL(string: posterURL) {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let status = (response as? HTTPURLResponse)?.statusCode, status < 200 || status > 200 { fatalError() }
                let image = UIImage(data: data)
                let model = MovieViewModel(movie: movie, image: image ?? UIImage(systemName: "questionmark.circle.fill")!)
                return .success(model)
            } catch {
                print(error)
                return .failure(error)
            }
        } else {
            let model = MovieViewModel(movie: movie, image: UIImage(systemName: "questionmark.circle.fill")!)
            return .success(model)
        }
        
    }
    
    func getPosters(from movies: [Movie]) async -> Result<[MovieViewModel], Error> {

        var models: [MovieViewModel] = []

        for movie in movies {
            if let model = try? await getPoster(for: movie).get() {
                models.append(model)
            }
        }
        
        return .success(models)

    }
    
}

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
