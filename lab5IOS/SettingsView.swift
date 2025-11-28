import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.accentColorKey) var selectedAccentColorData: Data = Color.yellow.encode()!
    @AppStorage(SettingsKeys.backgroundColorKey) var selectedBackgroundColorData: Data = Color.indigo.encode()!
    @AppStorage(SettingsKeys.fontSizeKey) var selectedFontSize: AppFontSize = .medium

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
