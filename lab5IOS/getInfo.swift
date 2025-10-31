import Foundation

// MARK: - Decodable Structs

struct Pokemon: Decodable {
    let id: Int
    let name: String
    
    let species: Species
    
    let abilities: [AbilitySlot]
    
    let stats: [StatSlot]
}

struct Species: Decodable {
    let name: String
    let url: String
}

struct AbilitySlot: Decodable {
    let ability: AbilityDetail
    let is_hidden: Bool
    let slot: Int
}

struct AbilityDetail: Decodable {
    let name: String
    let url: String
}

struct StatSlot: Decodable {
    let base_stat: Int
    let effort: Int
    let stat: StatDetail
}

struct StatDetail: Decodable {
    let name: String
}

// MARK: - API Client

class PokemonFetcher {
    private let baseURL = "https://pokeapi.co/api/v2/pokemon/"
   
    func fetchPokemon(identifier: String) async throws -> Pokemon {
        guard let url = URL(string: baseURL + identifier.lowercased()) else {
            throw PokemonError.invalidURL // Помилка недійсного URL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // checking response status
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if (response as? HTTPURLResponse)?.statusCode == 404 {
                throw PokemonError.pokemonNotFound(identifier)
            }
            throw PokemonError.networkError
        }
        
        // 2. Decoding JSON
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Pokemon.self, from: data)
        } catch {
            throw PokemonError.decodingError(error)
        }
    }
}

// MARK: - Errors

enum PokemonError: Error {
    case invalidURL
    case networkError
    case decodingError(Error)
    case pokemonNotFound(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Wrong URL."
        case .networkError:
            return "Network error."
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .pokemonNotFound(let identifier):
            return "Pokemon '\(identifier)' was not found."
        }
    }
}


