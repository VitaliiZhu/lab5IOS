import SwiftUI
import Combine
import Foundation

// MARK: - Моделі Налаштувань (UserDefaults / @AppStorage)

// Ключі для UserDefaults
struct SettingsKeys {
    static let accentColorKey = "appAccentColorData"
    static let backgroundColorKey = "appBackgroundColorData"
    static let fontSizeKey = "appFontSize"
}

// Перелік доступних розмірів шрифту
enum AppFontSize: String, Codable, CaseIterable, Identifiable {
    case small, medium, large
    var id: String { self.rawValue }

    func size() -> CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 18
        case .large: return 22
        }
    }
}

// MARK: - Color Persistence Helpers (Для збереження Color у UserDefaults)

extension Color {
    // Кодування Color у Data
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
    }

    // Декодування Data назад у Color
    static func decode(data: Data?) -> Color? {
        guard let data = data,
              let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor else { return nil }
        return Color(uiColor)
    }
}

// MARK: - Data Persistence Manager (FileManager)

class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    private let fileName = "latestPokemon.json"

    // Отримання шляху до каталогу Documents
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var fileURL: URL {
        getDocumentsDirectory().appendingPathComponent(fileName)
    }

    // Збереження даних (серіалізація Codable об'єкта)
    func save(pokemon: Pokemon) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pokemon)
            try data.write(to: fileURL, options: [.atomicWrite])
            print("🟢 Pokemon data saved successfully.")
        } catch {
            print("🔴 Error saving Pokemon data: \(error.localizedDescription)")
        }
    }

    // Завантаження даних (десеріалізація Codable об'єкта)
    func load() -> Pokemon? {
        if let data = try? Data(contentsOf: fileURL) {
            do {
                let decoder = JSONDecoder()
                let pokemon = try decoder.decode(Pokemon.self, from: data)
                print("🟢 Pokemon data loaded successfully.")
                return pokemon
            } catch {
                print("🔴 Error decoding Pokemon data: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
// MARK: - Codable Structs (Updated for Persistence and Display)

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int // Додано для відображення
    let weight: Int // Додано для відображення
    
    let species: Species
    let abilities: [AbilitySlot]
    let stats: [StatSlot]
    
    let sprites: PokemonSprites // Додано для відображення зображення
}

struct PokemonSprites: Codable {
    let front_default: String? // URL зображення
}

struct Species: Codable {
    let name: String
    let url: String
}

struct AbilitySlot: Codable {
    let ability: AbilityDetail
    let is_hidden: Bool
    let slot: Int
}

struct AbilityDetail: Codable {
    let name: String
    let url: String
}

struct StatSlot: Codable {
    let base_stat: Int
    let effort: Int
    let stat: StatDetail
}

struct StatDetail: Codable {
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


