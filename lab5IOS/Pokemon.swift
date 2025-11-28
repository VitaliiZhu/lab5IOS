struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    
    let species: Species
    let abilities: [AbilitySlot]
    let stats: [StatSlot]
    
    let sprites: PokemonSprites
}

struct PokemonSprites: Codable {
    let front_default: String?
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
