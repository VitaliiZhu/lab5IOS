import Foundation

// MARK: - Моделі даних (Decodable Structs)

/// Головна структура, що представляє Покемона, отриманого з PokeAPI
struct Pokemon: Decodable {
    let id: Int
    let name: String
    
    // Інформація про вид (Species)
    let species: Species
    
    // Список здібностей (Abilities)
    let abilities: [AbilitySlot]
    
    // Список характеристик/статистики (Stats)
    let stats: [StatSlot]
}

/// Деталі виду покемона
struct Species: Decodable {
    let name: String
    let url: String
}

/// Слот здібності
struct AbilitySlot: Decodable {
    let ability: AbilityDetail
    let is_hidden: Bool // Чи є здібність прихованою
    let slot: Int
}

/// Деталі здібності
struct AbilityDetail: Decodable {
    let name: String
    let url: String
}

/// Слот статистики/характеристики
struct StatSlot: Decodable {
    let base_stat: Int // Базове значення
    let effort: Int
    let stat: StatDetail
}

/// Деталі характеристики (назва)
struct StatDetail: Decodable {
    let name: String
}

// MARK: - Клієнт API

/// Клас для отримання даних про Покемонів
class PokemonFetcher {
    private let baseURL = "https://pokeapi.co/api/v2/pokemon/"
    
    /// Отримує дані про Покемона за його ID або назвою.
    /// - Parameter identifier: ID (Int) або назва (String) Покемона.
    /// - Returns: Об'єкт `Pokemon` з детальною інформацією.
    /// - Throws: `PokemonError` у випадку помилок мережі або декодування.
    func fetchPokemon(identifier: String) async throws -> Pokemon {
        guard let url = URL(string: baseURL + identifier.lowercased()) else {
            throw PokemonError.invalidURL // Помилка недійсного URL
        }
        
        // 1. Виконання мережевого запиту за допомогою async/await
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Перевірка статусу відповіді (очікуємо 200 OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // Спеціальна обробка для 404 Not Found
            if (response as? HTTPURLResponse)?.statusCode == 404 {
                throw PokemonError.pokemonNotFound(identifier)
            }
            throw PokemonError.networkError // Загальна помилка мережі
        }
        
        // 2. Декодування JSON даних у Swift структуру
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Pokemon.self, from: data)
        } catch {
            throw PokemonError.decodingError(error) // Помилка декодування
        }
    }
}

// MARK: - Обробка помилок

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


