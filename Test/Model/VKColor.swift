import UIKit

final class VKColor<Palette: Hashable> {

    let uiColor: UIColor

    init(hexLight: Int, hexDark: Int, alphaLight: CGFloat = 1.0, alphaDark: CGFloat = 1.0) {
        let lightColor = UIColor(hex: hexLight, alpha: alphaLight)
        let darkColor = UIColor(hex: hexDark, alpha: alphaDark)
        let uiColor = UIColor { $0.userInterfaceStyle == .light ? lightColor : darkColor }
        self.uiColor = uiColor
    }

    init(hexLight: Int, hexDark: Int, alpha: CGFloat = 1.0) {
        let vkColor = VKColor(
            hexLight: hexLight,
            hexDark: hexDark,
            alphaLight: alpha,
            alphaDark: alpha
        )
        self.uiColor = vkColor.uiColor
    }

    init(uiColor: UIColor) {
        self.uiColor = uiColor
    }
}

enum BackgroundPalette: Hashable {}

// MARK: - Background Colors

extension VKColor where Palette == BackgroundPalette {
    static let bgShimmering = VKColor(hexLight: 0xF3F3F7, hexDark: 0x242429)
}
