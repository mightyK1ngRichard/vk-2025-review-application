import UIKit

extension UIColor {

    /// Цвет текста, используемый для кнопки "Показать полностью...".
    static let showMore: UIColor = .systemBlue
    /// Цвет текста, используемый для отображения времени создания отзыва.
    static let created: UIColor = .secondaryLabel
    /// Цвет текста, используемый для отображения общего количества отзывов.
    static let reviewCount: UIColor = .secondaryLabel
    /// Цвет шиммера.
    static let shimmiring = UIColor {
        $0.userInterfaceStyle == .light ? UIColor(hex: 0xF3F3F7) : UIColor(hex: 0x242429)
    }

}
