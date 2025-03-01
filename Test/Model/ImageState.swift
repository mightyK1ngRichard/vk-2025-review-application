import Foundation

enum ImageState: Hashable, Sendable, Equatable {
    case success(Data)
    case failure
    case loading
}
