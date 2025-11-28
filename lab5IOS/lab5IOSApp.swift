import SwiftUI

@main
struct lab5IOSApp: App {
    
    
    init() {
        let defaultAccentColor = Color.yellow
        let defaultBgColor = Color.indigo
        // Move to UserDefaultsManager
        if UserDefaults.standard.data(forKey: SettingsKeys.accentColorKey) == nil,
           let data = defaultAccentColor.encode() {
            UserDefaults.standard.set(data, forKey: SettingsKeys.accentColorKey)
        }
        if UserDefaults.standard.data(forKey: SettingsKeys.backgroundColorKey) == nil,
           let data = defaultBgColor.encode() {
            UserDefaults.standard.set(data, forKey: SettingsKeys.backgroundColorKey)
        }
        if UserDefaults.standard.string(forKey: SettingsKeys.fontSizeKey) == nil {
            UserDefaults.standard.set(AppFontSize.medium.rawValue, forKey: SettingsKeys.fontSizeKey)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
