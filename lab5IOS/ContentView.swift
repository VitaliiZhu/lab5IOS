//
//  ContentView.swift
//  lab5IOS
//
//  Created by ІПЗ-31/1 on 31.10.2025.
//

import SwiftUI

struct ContentView: View  {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var pokemonName: String = "pikachu"
    
    // Завантаження налаштувань
    @AppStorage(SettingsKeys.accentColorKey) var selectedAccentColorData: Data = Color.yellow.encode()!
    @AppStorage(SettingsKeys.backgroundColorKey) var selectedBackgroundColorData: Data = Color.indigo.encode()!
    @AppStorage(SettingsKeys.fontSizeKey) var selectedFontSize: AppFontSize = .medium
    
    var appAccentColor: Color {
        Color.decode(data: selectedAccentColorData) ?? .yellow
    }
    
    var appBackgroundColorBase: Color {
        Color.decode(data: selectedBackgroundColorData) ?? .indigo
    }
    
    // Динамічний градієнт на основі налаштувань
    var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [appBackgroundColorBase, .blue, .teal]), startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        // TabView для перемикання між функціоналом та налаштуваннями
        TabView {
            // --- 1. Головний Екран (Pokemon Viewer) ---
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // Використання налаштованого кольору для тексту та розміру шрифту
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
                        // Застосування налаштованого кольору акценту до кнопки
                        .tint(appAccentColor)
                        .foregroundColor(Color(uiColor: .systemBackground))
                        .font(.system(size: 16, weight: .bold))
                        
                        // MARK: - Кнопки Збереження / Завантаження
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
                        
                        // Повідомлення про статус (збереження/завантаження/помилка)
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
            
            // --- 2. Екран Налаштувань ---
            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gearshape.fill")
                }
        }
        .tint(appAccentColor) // Застосування кольору акценту до TabView
    }
}
struct PokemonDataView: View {
    // Завантаження налаштувань стилю
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
            
            // Зображення (AsyncImage)
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
                // Використовуємо height та weight
                Text("Вага: \(pokemon.weight/10) кг | Зріст: \(pokemon.height/10) м")
            }
            .font(.system(size: selectedFontSize.size(), weight: .bold))
            .padding(.bottom, 10)

            Divider()
                .background(appAccentColor)

            // Статистика
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
            
            // Здібності
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
        .foregroundColor(appAccentColor) // Застосування Accent Color
        .shadow(color: appAccentColor.opacity(0.5), radius: 5)
    }
}

struct SettingsView: View {
    // @AppStorage для автоматичного збереження/завантаження
    @AppStorage(SettingsKeys.accentColorKey) var selectedAccentColorData: Data = Color.yellow.encode()!
    @AppStorage(SettingsKeys.backgroundColorKey) var selectedBackgroundColorData: Data = Color.indigo.encode()!
    @AppStorage(SettingsKeys.fontSizeKey) var selectedFontSize: AppFontSize = .medium

    // Доступні опції кольорів
    let availableAccentColors: [(name: String, color: Color)] = [
        ("Жовтий (Default)", .yellow),
        ("Червоний", .red),
        ("Зелений", .green),
        ("Білий", .white)
    ]

    let availableBackgroundColors: [(name: String, color: Color)] = [
        ("Синій/Фіолетовий (Default)", Color.indigo),
        ("Океан (Teal)", Color.teal),
        ("Вогонь (Orange)", Color.orange)
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // --- Опція 1: Колір Акценту (Шрифт та Кнопки) ---
                Section(header: Text("Колір Акценту (Текст та Кнопки)")) {
                    Picker("Колір", selection: $selectedAccentColorData) {
                        ForEach(availableAccentColors, id: \.name) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 20, height: 20)
                            }
                            .tag(item.color.encode()!)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // --- Опція 2: Колір Фонової Бази Градієнту ---
                Section(header: Text("Базовий Колір Фонового Градієнту")) {
                    Picker("Базовий Колір", selection: $selectedBackgroundColorData) {
                        ForEach(availableBackgroundColors, id: \.name) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 20, height: 20)
                            }
                            .tag(item.color.encode()!)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // --- Опція 3: Розмір Шрифту ---
                Section(header: Text("Розмір Основного Шрифту")) {
                    Picker("Розмір", selection: $selectedFontSize) {
                        ForEach(AppFontSize.allCases) { size in
                            Text(size.rawValue.capitalized)
                                .tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Приклад шрифту").font(.system(size: selectedFontSize.size()))
                }
            }
            .navigationTitle("Налаштування Додатку")
        }
    }
}
#Preview {
    ContentView()
}
