import SwiftUI
import Foundation

@MainActor
final class PokemonViewModel: ObservableObject {
    
    @Published private(set) var pokemon: Pokemon?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var statusMessage: String?
    
    private let fetcher = PokemonFetcher()

    init() {
        self.loadLastPokemon(silent: true)
    }

    
    func loadPokemon(identifier: String) {
        Task {
            self.isLoading = true
            self.errorMessage = nil
            self.statusMessage = nil
            
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
    
    
    func saveCurrentPokemon() {
        guard let currentPokemon = pokemon else {
            statusMessage = "Немає даних для збереження."
            return
        }
        
        DataPersistenceManager.shared.save(pokemon: currentPokemon)
        statusMessage = "Поточний Покемон (\(currentPokemon.name.capitalized)) успішно збережено у локальний файл."
    }
    
    func loadLastPokemon(silent: Bool = false) {
        let lastPokemon = DataPersistenceManager.shared.load()
        
        if let lastPokemon = lastPokemon {
            self.pokemon = lastPokemon
            if !silent {
                statusMessage = "Успішно завантажено останнього збереженого Покемона: \(lastPokemon.name.capitalized)."
            }
        } else {
            self.pokemon = nil
            if !silent {
                statusMessage = "Локальні збережені дані не знайдено."
            }
        }
    }
}
