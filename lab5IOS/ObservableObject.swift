import SwiftUI

/// ViewModel для відображення даних про Покемона
@MainActor // Гарантує, що всі зміни стану відбуваються в основному потоці
final class PokemonViewModel: ObservableObject {
    // Властивості, які оновлюватимуть View
    @Published private(set) var pokemon: Pokemon? // Завантажені дані
    @Published private(set) var isLoading = false // Стан завантаження
    @Published private(set) var errorMessage: String? // Повідомлення про помилку
    
    // Екземпляр вашого Fetcher'а
    private let fetcher = PokemonFetcher()

    /// Завантажує дані про Покемона.
    func loadPokemon(identifier: String) {
        // Запуск асинхронної роботи в Task
        Task {
            // Скидання попереднього стану
            self.isLoading = true
            self.errorMessage = nil
            self.pokemon = nil
            
            do {
                // Виклик вашої асинхронної функції
                let fetchedPokemon = try await fetcher.fetchPokemon(identifier: identifier)
                
                // Успішне оновлення
                self.pokemon = fetchedPokemon
                
            } catch {
                // Обробка помилки
                if let pokemonError = error as? PokemonError {
                    self.errorMessage = pokemonError.localizedDescription
                } else {
                    self.errorMessage = "UnknownError: \(error.localizedDescription)"
                }
            }
            
            // Завершення завантаження
            self.isLoading = false
        }
    }
}
