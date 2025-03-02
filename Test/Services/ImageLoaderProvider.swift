import Foundation
import UIKit

protocol ImageLoaderProvider: AnyObject {

    func fetchImagesData(
        from urlsStrings: [String],
        completion: @escaping (ImageLoaderProviderImpl.GetImagesStatesResult) -> Void
    )

}

// MARK: - ImageLoaderProviderImpl

final class ImageLoaderProviderImpl: ImageLoaderProvider {

    typealias GetUIImageResult = Result<UIImage, ImageLoaderError>
    typealias GetImagesStatesResult = [(url: String, state: ImageState)]

    private let session: URLSession
    private var imageCache: NSCache<NSString, NSData>
    private let fileManager: FileManagerImageHashProtocol

    private let cacheQueue = DispatchQueue(label: "com.vk.imageLoader.cacheQueue")
    private let imageQueue = DispatchQueue(
        label: "com.vk.imageLoader.imageQueue",
        qos: .userInteractive,
        attributes: [.concurrent]
    )

    init(
        session: URLSession = URLSession.shared,
        imageCache: NSCache<NSString, NSData> = NSCache<NSString, NSData>(),
        fileManager: FileManagerImageHashProtocol = FileManagerImageHash.shared
    ) {
        self.session = session
        self.imageCache = imageCache
        self.fileManager = fileManager
    }

    func fetchImagesData(
        from urlsStrings: [String],
        completion: @escaping (GetImagesStatesResult) -> Void
    ) {
        let group = DispatchGroup()
        let lock = NSLock()
        var results: GetImagesStatesResult = []

        for urlString in urlsStrings {
            // Если есть в кэше, возвращаем
            if let imageData = imageCache.object(forKey: urlString as NSString),
               let uiImage = UIImage(data: imageData as Data) {
                results.append((urlString, .success(uiImage)))
                continue
            }

            // Если есть в файловом хранилище
            if let uiImage = fileManager.getImage(key: urlString) {
                results.append((urlString, .success(uiImage)))
                continue
            }

            group.enter()
            imageQueue.async {
                self.fetchImageData(from: urlString) { result in
                    lock.lock()
                    switch result {
                    case let .success(uiImage):
                        results.append((urlString, .success(uiImage)))
                    case .failure:
                        results.append((urlString, .failure))
                    }
                    group.leave()
                    lock.unlock()
                }
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

}

// MARK: - Private

private extension ImageLoaderProviderImpl {

    func fetchImageData(
        from urlString: String,
        completion: @escaping (GetUIImageResult) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageLoaderError.badURL))
            return
        }

        let request = URLRequest(url: url, timeoutInterval: 10)
        session.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
                completion(.failure(ImageLoaderError.badData(error)))
                return
            }
            guard
                let data,
                let uiImage = UIImage(data: data)
            else {
                completion(.failure(ImageLoaderError.DataIsNil))
                return
            }

            completion(.success(uiImage))

            // Кэшируем
            fileManager.saveImage(uiImage: uiImage, for: urlString, completion: nil)
            cacheQueue.sync {
                self.imageCache.setObject(data as NSData, forKey: urlString as NSString)
            }
        }.resume()
    }

}

// MARK: - ImageLoaderError

extension ImageLoaderProviderImpl {

    enum ImageLoaderError: Error {

        case badURL
        case DataIsNil
        case badData(Error)

    }

}
