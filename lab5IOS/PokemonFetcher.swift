import SwiftUI
import Combine
import Foundation


class PokemonFetcher {
    private let baseURL = "https://pokeapi.co/api/v2/pokemon/"
   
    func fetchPokemon(identifier: String) async throws -> Pokemon {
        guard let url = URL(string: baseURL + identifier.lowercased()) else {
            throw PokemonError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 404 {
                throw PokemonError.pokemonNotFound(identifier)
            }
            throw PokemonError.networkError
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Pokemon.self, from: data)
        } catch {
            throw PokemonError.decodingError(error)
        }
    }
}

