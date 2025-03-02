import UIKit

enum ImageState: Hashable, Sendable, Equatable {
    case success(UIImage)
    case failure
    case loading
}
