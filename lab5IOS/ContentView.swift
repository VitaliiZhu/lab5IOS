import SwiftUI

struct ContentView: View  {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var pokemonName: String = "pikachu"
    
    @AppStorage(SettingsKeys.accentColorKey) var selectedAccentColorData: Data = Color.yellow.encode()!
    @AppStorage(SettingsKeys.backgroundColorKey) var selectedBackgroundColorData: Data = Color.indigo.encode()!
    @AppStorage(SettingsKeys.fontSizeKey) var selectedFontSize: AppFontSize = .medium
    
    var appAccentColor: Color {
        Color.decode(data: selectedAccentColorData) ?? .yellow
    }
    var appBackgroundColorBase: Color {
        Color.decode(data: selectedBackgroundColorData) ?? .indigo
    }
    var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [appBackgroundColorBase, .blue, .teal]), startPoint: .top, endPoint: .bottom)
    }
    var body: some View {
        TabView {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        Image("PokemonLogo").resizable()
                                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        Text("Pokemon information")
                            .font(.system(size: 35, weight: .black))
                            .foregroundColor(appAccentColor)
                            .padding(.top, 40)
                        HStack {
                            Text("Insert a name or ID of Pokemon")
                                .font(.system(size: selectedFontSize.size() * 1.1, weight: .heavy))
                                .foregroundColor(appAccentColor)
                            TextField("", text: $pokemonName)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 5)
                        }
                        .padding(.horizontal)
                        Button("Load a Pokemon") {
                            viewModel.loadPokemon(identifier: pokemonName)
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                        .tint(appAccentColor)
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .font(.system(size: 16, weight: .bold))
                       HStack(spacing: 20) {
                            Button("Зберегти Поточні Дані") {
                                viewModel.saveCurrentPokemon()
                            }
                            .buttonStyle(.bordered)
                            .tint(appAccentColor)
                            Button("Завантажити Збережені Дані") {
                                viewModel.loadLastPokemon()
                            }
                            .buttonStyle(.bordered)
                            .tint(appAccentColor)
                        }
                        .padding(.bottom, 10)
                        if let status = viewModel.statusMessage {
                            Text(status)
                                .foregroundColor(appAccentColor)
                                .font(.system(size: 14))
                                .padding(.vertical, 5)
                        }
                        Divider()
                            .background(appAccentColor)
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .foregroundColor(appAccentColor)
                                .font(.system(size: 16, weight: .bold))
                        } else if let errorMessage = viewModel.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else if let pokemon = viewModel.pokemon {
                            PokemonDataView(pokemon: pokemon)
                                .padding(.horizontal)
                        } else {
                            Text("Введіть ім'я або ID та натисніть кнопку Load.")
                                .foregroundColor(appAccentColor)
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .tabItem {
                Label("Пошук", systemImage: "magnifyingglass")
            }
            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gearshape.fill")
                }
        }
        .tint(appAccentColor)
    }
}

#Preview {
    ContentView()
}
