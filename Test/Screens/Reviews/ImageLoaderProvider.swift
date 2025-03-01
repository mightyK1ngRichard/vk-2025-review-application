import Foundation

protocol ImageLoaderProvider: AnyObject {

    func fetchImagesData(
        from urlsStrings: [String],
        completion: @escaping (ImageLoaderProviderImpl.GetImagesStatesResult) -> Void
    )

}

// MARK: - ImageLoaderProviderImpl

final class ImageLoaderProviderImpl: ImageLoaderProvider {

    typealias GetImageDataResult = Result<Data, ImageLoaderError>
    typealias GetImagesStatesResult = [(url: String, state: ImageState)]

    private let session = URLSession.shared
    private var imageCache = NSCache<NSString, NSData>()

    private let cacheQueue = DispatchQueue(label: "com.vk.imageLoader.cacheQueue")
    private let imageQueue = DispatchQueue(
        label: "com.vk.imageLoader.imageQueue",
        qos: .userInteractive,
        attributes: [.concurrent]
    )

    func fetchImagesData(
        from urlsStrings: [String],
        completion: @escaping (GetImagesStatesResult) -> Void
    ) {
        let group = DispatchGroup()
        let lock = NSLock()
        var results: GetImagesStatesResult = []

        for urlString in urlsStrings {
            group.enter()
            imageQueue.async {
                self.fetchImageData(from: urlString) { result in
                    lock.lock()
                    switch result {
                    case let .success(imageData):
                        results.append((urlString, .success(imageData)))
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
        completion: @escaping (GetImageDataResult) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageLoaderError.badURL))
            return
        }

        // Если есть в кэше, возвращаем
        if let imageData = imageCache.object(forKey: urlString as NSString) {
            completion(.success(imageData as Data))
            return
        }

        let request = URLRequest(url: url, timeoutInterval: 10)
        session.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
                completion(.failure(ImageLoaderError.badData(error)))
                return
            }
            guard let data else {
                completion(.failure(ImageLoaderError.DataIsNil))
                return
            }

            completion(.success(data))

            // Кэшируем
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
