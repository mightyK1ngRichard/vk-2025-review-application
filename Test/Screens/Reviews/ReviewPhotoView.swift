import UIKit

final class ReviewPhotoView: UIView {

    var imageState: ImageState

    private let imageView = UIImageView()
    private let errorImageView = UIImageView()

    init(imageState: ImageState = .loading) {
        self.imageState = imageState
        super.init(frame: .zero)
        setup()
        updateImageView()
    }

    override init(frame: CGRect) {
        self.imageState = .loading
        super.init(frame: frame)
        setup()
        updateImageView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        errorImageView.frame = CGRect(
            origin: CGPoint(
                x: (bounds.width - Constants.errorImageSize) / 2,
                y: (bounds.height - Constants.errorImageSize) / 2
            ),
            size: CGSize(width: Constants.errorImageSize, height: Constants.errorImageSize)
        )
    }

    func updateImage(with imageState: ImageState) {
        self.imageState = imageState
        updateImageView()
    }
}

// MARK: - Private

private extension ReviewPhotoView {

    func setup() {
        setPhotoImageView()
        setErrorImageView()
    }

    func setPhotoImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
    }

    func setErrorImageView() {
        addSubview(errorImageView)
        errorImageView.image = UIImage(systemName: "exclamationmark.circle")
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.tintColor = .white
        errorImageView.isHidden = true
    }

    func updateImageView() {
        switch imageState {
        case let .success(imageData):
            backgroundColor = .clear
            imageView.image = UIImage(data: imageData)
            errorImageView.isHidden = true
        case .failure:
            backgroundColor = .systemGray4
            imageView.image = nil
            errorImageView.isHidden = false
        case .loading:
            backgroundColor = .systemGray4
            imageView.image = nil
            errorImageView.isHidden = true
        }
    }
}

// MARK: - Constants

private extension ReviewPhotoView {

    enum Constants {
        static let errorImageSize: CGFloat = 20
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    final class TestViewController: UIViewController {
        let testView = ReviewPhotoView()
        let button = {
            let button = UIButton()
            var config = UIButton.Configuration.borderedProminent()
            config.title = "Update state"
            button.configuration = config
            return button
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(testView)
            view.addSubview(button)
            testView.frame = .init(x: 50, y: 150, width: 55, height: 66)
            button.frame = .init(x: 50, y: 500, width: 200, height: 30)
            testView.layer.cornerRadius = 8
            testView.layer.masksToBounds = true
            button.addAction(
                UIAction { _ in
                    self.testView.updateImage(
                        with: Bool.random()
                         ? ImageState.success(UIImage(resource: .IMG_0004).pngData()!)
                        : ImageState.failure
                    )
                },
                for: .touchUpInside)
        }
    }

    return TestViewController()
}
