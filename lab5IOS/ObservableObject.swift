import SwiftUI


@MainActor
final class PokemonViewModel: ObservableObject {
    
    @Published private(set) var pokemon: Pokemon?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    
    private let fetcher = PokemonFetcher()

    
    func loadPokemon(identifier: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            self.pokemon = nil
            
            do {
                let fetchedPokemon = try await fetcher.fetchPokemon(identifier: identifier)
                
                self.pokemon = fetchedPokemon
                
            } catch {
                if let pokemonError = error as? PokemonError {
                    self.errorMessage = pokemonError.localizedDescription
                } else {
                    self.errorMessage = "UnknownError: \(error.localizedDescription)"
                }
            }
            self.isLoading = false
        }
    }
}
