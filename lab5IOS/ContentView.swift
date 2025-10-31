//
//  ContentView.swift
//  lab5IOS
//
//  Created by ІПЗ-31/1 on 31.10.2025.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = PokemonViewModel()
        @State private var pokemonName: String = "pikachu" // Приклад початкового значення
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.indigo , .blue ,  .teal]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView{
                VStack {
                    Image("PokemonLogo").resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    Text("Pokemon information").font(.system(size: 35,weight: .black))
                        .foregroundColor(.yellow)
                    HStack {
                        Text("Insert a name or ID of Pokemon").font(.system(size: 21, weight:     .heavy)).foregroundColor(.yellow)
                        TextField("",text : $pokemonName).textFieldStyle(.roundedBorder)
                            .padding()
                    }
                    Button("Load a Pokemon") {
                        viewModel.loadPokemon(identifier: pokemonName)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .bold))
                    
                    Divider()
                    
                    // Відображення стану
                    if viewModel.isLoading {
                        // Стан завантаження
                        ProgressView("Loading...")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .bold))
                    } else if let errorMessage = viewModel.errorMessage {
                        // Стан помилки
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if let pokemon = viewModel.pokemon {
                        // Стан успіху: Відображення даних Покемона
                        PokemonDataView(pokemon: pokemon)
                    } else {
                        // Початковий стан
                        Text("Insert a name and press the load button.")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .padding()
            }
        }
    }
}
struct PokemonDataView: View {
    let pokemon: Pokemon
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("**ID:** \(pokemon.id)")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .bold))
                Text("**Name:** \(pokemon.name.capitalized)")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .bold))
                
                Divider()
                
                Text("**Stats:**")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .bold))
                ForEach(pokemon.stats, id: \.stat.name) { statSlot in
                    HStack {
                        Text("- \(statSlot.stat.name.capitalized):")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text("**\(statSlot.base_stat)**")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                
                Divider()
                
                Text("**Abilities:**")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .bold))
                ForEach(pokemon.abilities, id: \.ability.name) { abilitySlot in
                    Text("- \(abilitySlot.ability.name.capitalized) \(abilitySlot.is_hidden ? "(Hidden)" : "")")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding()
        }
    }
}
#Preview {
    ContentView()
}
