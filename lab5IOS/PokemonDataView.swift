import SwiftUI
struct PokemonDataView: View {
    @AppStorage(SettingsKeys.fontSizeKey) var selectedFontSize: AppFontSize = .medium
    @AppStorage(SettingsKeys.accentColorKey) var selectedAccentColorData: Data = Color.yellow.encode()!
    
    var appAccentColor: Color {
        Color.decode(data: selectedAccentColorData) ?? .yellow
    }
    let pokemon: Pokemon
    var imageURL: URL? {
        if let urlString = pokemon.sprites.front_default {
            return URL(string: urlString)
        }
        return nil
    }
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Image(systemName: "photo.fill").resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray)
                    } else {
                        ProgressView().progressViewStyle(.circular)
                    }
                }
                .frame(width: 150, height: 150)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("ID: \(pokemon.id)")
                Text("Ім'я: \(pokemon.name.capitalized)")
                Text("Вага: \(pokemon.weight/10) кг | Зріст: \(pokemon.height/10) м")
            }
            .font(.system(size: selectedFontSize.size(), weight: .bold))
            .padding(.bottom, 10)
            Divider()
                .background(appAccentColor)
            VStack(alignment: .leading, spacing: 8) {
                Text("Статистика:").fontWeight(.heavy)
                ForEach(pokemon.stats, id: \.stat.name) { statSlot in
                    HStack {
                        Text("- \(statSlot.stat.name.capitalized):")
                        Spacer()
                        Text("\(statSlot.base_stat)")
                    }
                }
            }
            .font(.system(size: selectedFontSize.size() * 0.9))
            .padding(.horizontal)
            VStack(alignment: .leading, spacing: 8) {
                Text("Здібності:").fontWeight(.heavy)
                ForEach(pokemon.abilities, id: \.ability.name) { abilitySlot in
                    Text("- \(abilitySlot.ability.name.capitalized) \(abilitySlot.is_hidden ? "(Прихована)" : "")")
                }
            }
            .font(.system(size: selectedFontSize.size() * 0.9))
            .padding(.horizontal)
        }
        .padding()
        .background(Color.black.opacity(0.15))
        .cornerRadius(15)
        .foregroundColor(appAccentColor)
        .shadow(color: appAccentColor.opacity(0.5), radius: 5)
    }
}
