import Foundation

/// Модель отзыва.
struct Review: Decodable {
    
    /// Код отзыва.
    let id = UUID()
    /// Имя пользователя.
    let firstName: String
    /// Фамилия пользователя.
    let lastName: String
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Рейтинг отзыва.
    let rating: Int
    /// Фотографии в отзыве.
    let photoUrls: [String]?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case photoUrls = "photo_urls"
        case text
        case created
        case rating
    }

}
