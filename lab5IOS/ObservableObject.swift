import SwiftUI
import Foundation

@MainActor
final class PokemonViewModel: ObservableObject {
    
    @Published private(set) var pokemon: Pokemon?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var statusMessage: String? // Нове поле для відображення статусу збереження/завантаження
    
    // Припускається, що PokemonFetcher та PokemonError визначені
    private let fetcher = PokemonFetcher()

    // Ініціалізація: Завантаження останнього збереженого Покемона з FileManager
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
                
                // Автоматичне збереження нових даних у FileManager
//                DataPersistenceManager.shared.save(pokemon: fetchedPokemon)
//                self.statusMessage = "Покемон '\(fetchedPokemon.name.capitalized)' успішно завантажено та збережено!"
                
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
    
    // MARK: - Ручне Збереження/Завантаження
    
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
            self.pokemon = nil // Скидаємо, якщо не вдалося завантажити
            if !silent {
                statusMessage = "Локальні збережені дані не знайдено."
            }
        }
    }
}
