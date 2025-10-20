import SwiftUI

enum DesignTokens {
    enum ColorPalette {
        static let primary = Color(red: 10 / 255, green: 132 / 255, blue: 255 / 255)
        static let success = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
        static let warning = Color(red: 255 / 255, green: 149 / 255, blue: 0 / 255)
        static let critical = Color(red: 255 / 255, green: 59 / 255, blue: 48 / 255)
        static let background = Color(.systemBackground)
    }

    enum Typography {
        static let title = Font.system(size: 24, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    }

    enum Layout {
        static let cornerRadiusSmall: CGFloat = 12
        static let cornerRadiusMedium: CGFloat = 16
        static let cornerRadiusLarge: CGFloat = 24
        static let standardPadding: CGFloat = 16
    }
}
