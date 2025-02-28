import UIKit
import Combine

final class ReviewsViewController: UIViewController {

    typealias DataSource = UITableViewDiffableDataSource<ReviewsViewModel.Section, ReviewCellConfig>

    private lazy var reviewsView = makeReviewsView()
    private lazy var diffableDataSource = makeDataSource()
    private let viewModel: ReviewsViewModel
    private var store = Set<AnyCancellable>()

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        subscribe()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getReviews()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.onRefresh = { [weak self] refreshControl in
            self?.viewModel.refreshReviews()
            refreshControl.endRefreshing()
        }
        reviewsView.tableView.delegate = viewModel
        return reviewsView
    }

    func subscribe() {
        reviewsView.loadingIndicator.startAnimating()
        viewModel.$showLoader
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isShowing in
                guard let self else { return }
                if isShowing {
                    reviewsView.loadingIndicator.startAnimating()
                    reviewsView.tableView.isHidden = true
                } else {
                    reviewsView.loadingIndicator.stopAnimating()
                    reviewsView.tableView.isHidden = false
                }
            }
            .store(in: &store)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                reviewsView.updateFooterLabel(with: state.items.count)
            }
            .store(in: &store)

        viewModel.$snapshot
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.diffableDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &store)
    }

    func makeDataSource() -> DataSource {
        DataSource(tableView: reviewsView.tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: itemIdentifier.reuseId, for: indexPath)
            itemIdentifier.update(cell: cell)
            return cell
        }
    }

}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    let reviewsProvider = ReviewsProvider()
    let viewModel = ReviewsViewModel(reviewsProvider: reviewsProvider)
    ReviewsViewController(viewModel: viewModel)
}
