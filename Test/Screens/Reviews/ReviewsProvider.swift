import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {

    private let bundle: Bundle
    private let networkQueue = DispatchQueue(
        label: "com.vk.reviewsProvider.networkQueue",
        qos: .userInitiated,
        attributes: [.concurrent]
    )
    private var activeRequests: [DispatchWorkItem] = []

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

}

// MARK: - Internal

extension ReviewsProvider {

    typealias GetReviewsResult = Result<Data, GetReviewsError>

    enum GetReviewsError: Error {

        case badURL
        case badData(Error)

    }

    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            return completion(.failure(.badURL))
        }

        // Симулируем сетевой запрос - не менять
        let workItem = DispatchWorkItem {
            usleep(.random(in: 100_000...1_000_000))

            do {
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch {
                completion(.failure(.badData(error)))
            }
        }
        activeRequests.append(workItem)
        networkQueue.async(execute: workItem)
    }

    func cancelAllRequests() {
        activeRequests.forEach { $0.cancel() }
        activeRequests.removeAll()
    }

}
