import UIKit
import Combine

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ReviewCellConfig>

    @Published private(set) var footerText: String?
    @Published private(set) var showLoader: Bool
    @Published private(set) var openImageZooming: UIImage?
    @Published private(set) var snapshot: DataSourceSnapshot

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let imageLoaderProvider: ImageLoaderProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    private var store = Set<AnyCancellable>()

    init(
        state: State = State(),
        showLoader: Bool = false,
        snapshot: DataSourceSnapshot = DataSourceSnapshot(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        imageLoaderProvider: ImageLoaderProvider = ImageLoaderProviderImpl(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.showLoader = showLoader
        self.snapshot = snapshot
        self.reviewsProvider = reviewsProvider
        self.imageLoaderProvider = imageLoaderProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

    enum Section: Hashable {
        case review
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        if state.offset == 0 {
            showLoader = true
        }
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            self?.gotReviews(result)
        }
    }

    func refreshReviews(completion: @escaping () -> Void) {
        state.shouldLoad = false
        reviewsProvider.getReviews() { [weak self] result in
            self?.refreshedReviews(result)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            makeSnapshot()
            footerText = "\(state.items.count) отзывов"
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            // Загружаем фотографии из сети
            reviews.items.forEach { item in
                fetchImages(for: item)
            }
        } catch {
            state.shouldLoad = true
        }

        if showLoader {
            showLoader = false
        }
    }

    func refreshedReviews(_ result: ReviewsProvider.GetReviewsResult) {
        // Если рефреш, обновляем все данные и сбрасываем пагинацию
        state.reset()
        // TODO: Надо отменить созданные таски сервиса изображений
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items = reviews.items.map(makeReviewItem)
            makeSnapshot()
            footerText = "\(state.items.count) отзывов"
            state.offset = state.limit
            state.shouldLoad = state.offset < reviews.count
            // Загружаем фотографии из сети
            reviews.items.forEach { item in
                fetchImages(for: item)
            }
        } catch {
            state.shouldLoad = true
        }
    }

    func fetchImages(for item: Review) {
        guard let urlStrings = item.photoUrls else { return }
        imageLoaderProvider.fetchImagesData(from: urlStrings) { [weak self] urlsWithState in
            guard
                let self,
                let index = state.items.firstIndex(where: { $0.id as? UUID == item.id }),
                var updatedReview = state.items[index] as? ReviewCellConfig
            else { return }

            updatedReview.photosState = urlsWithState.map(\.state)
            state.items[index] = updatedReview
            makeSnapshot()
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        makeSnapshot()
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let userName = (review.firstName + " " + review.lastName).attributed(font: .username)
        let raitingImage = ratingRenderer.ratingImage(review.rating)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let item = ReviewItem(
            id: review.id,
            username: userName,
            reviewText: reviewText,
            raitingImage: raitingImage,
            photosState: review.photoUrls?.map { _ in .loading } ?? [],
            created: created,
            onTapShowMore: { [weak self] in
                self?.showMoreReview(with: $0)
            },
            onTapPhoto: { [weak self] uiImage in
                self?.openImageZooming = uiImage
            }
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel {

    func makeSnapshot() {
        var snapshot = DataSourceSnapshot()
        defer { self.snapshot = snapshot }
        snapshot.appendSections([.review])
        snapshot.appendItems(state.items as? [ReviewCellConfig] ?? [])
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
