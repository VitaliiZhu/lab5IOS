import SwiftUI
import Combine
import Foundation



struct SettingsKeys {
    static let accentColorKey = "appAccentColorData"
    static let backgroundColorKey = "appBackgroundColorData"
    static let fontSizeKey = "appFontSize"
}

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


extension Color {
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false)
    }

    static func decode(data: Data?) -> Color? {
        guard let data = data,
              let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor else { return nil }
        return Color(uiColor)
    }
}
