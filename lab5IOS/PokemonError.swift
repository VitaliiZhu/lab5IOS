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
