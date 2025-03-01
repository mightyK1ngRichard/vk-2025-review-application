import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    lazy var loadingIndicator = CustomActivityIndicator(
        frame: CGRect(
            origin: center,
            size: CGSize(width: 30, height: 30)
        )
    )
    var onRefresh: ((UIRefreshControl) -> Void)? = nil
    private let footerLabel = UILabel()
    private let refreshControl = UIRefreshControl()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
        loadingIndicator.center = center
        loadingIndicator.center = center
        footerLabel.frame = CGRect(
            origin: CGPoint(x: 0, y: tableView.contentSize.height),
            size: CGSize(width: bounds.width, height: Constants.footerHeight)
        )
    }

    func updateFooterLabel(with count: Int) {
        footerLabel.text = "\(count) отзывов"
    }
}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupRefreshView()
        setupTableView()
        setupLoadingIndicator()
    }

    func setupLoadingIndicator() {
        addSubview(loadingIndicator)
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.tableFooterView = footerLabel
        tableView.refreshControl = refreshControl
        setupFooterLabel()
    }

    func setupRefreshView() {
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            onRefresh?(refreshControl)
        }
        refreshControl.addAction(action, for: .valueChanged)
    }

    func setupFooterLabel() {
        footerLabel.textAlignment = .center
        footerLabel.font = .reviewCount
        footerLabel.textColor = .reviewCount
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    let reviewsProvider = ReviewsProvider()
    let viewModel = ReviewsViewModel(reviewsProvider: reviewsProvider)
    ReviewsViewController(viewModel: viewModel)
}

// MARK: - Constants

private extension ReviewsView {

    enum Constants {
        /// Высота футера таблицы.
        static let footerHeight: CGFloat = 50
    }

}
