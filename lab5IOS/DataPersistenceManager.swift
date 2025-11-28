import SwiftUI
import Combine
import Foundation

class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    private let fileName = "latestPokemon.json"

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var fileURL: URL {
        getDocumentsDirectory().appendingPathComponent(fileName)
    }

    func save(pokemon: Pokemon) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pokemon)
            try data.write(to: fileURL, options: [.atomicWrite])
            print(" Pokemon data saved successfully.")
        } catch {
            print(" Error saving Pokemon data: \(error.localizedDescription)")
        }
    }

    func load() -> Pokemon? {
        if let data = try? Data(contentsOf: fileURL) {
            do {
                let decoder = JSONDecoder()
                let pokemon = try decoder.decode(Pokemon.self, from: data)
                print(" Pokemon data loaded successfully.")
                return pokemon
            } catch {
                print(" Error decoding Pokemon data: \(error.localizedDescription)")
            }
        }
        return nil
    }
}



