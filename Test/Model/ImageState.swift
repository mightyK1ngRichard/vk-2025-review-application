import Foundation

enum ImageState: Hashable, Sendable {
    case success(Data)
    case failure
    case loading
}
