import UIKit

final class ReviewPhotoView: UIView {

    var imageState: ImageState
    var onTapImage: ((UIImage) -> Void)? = nil

    private let shimmeringView = ShimmerView()
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
        shimmeringView.frame = bounds
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
        guard imageState != self.imageState else {
            return
        }
        self.imageState = imageState
        updateImageView()
    }
}

// MARK: - Private

private extension ReviewPhotoView {

    func setup() {
        setShimmeringView()
        setPhotoImageView()
        setErrorImageView()
        addAction()
    }

    func setShimmeringView() {
        addSubview(shimmeringView)
    }

    func setPhotoImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
    }

    func setErrorImageView() {
        addSubview(errorImageView)
        errorImageView.image = UIImage(systemName: "exclamationmark.circle")
        errorImageView.contentMode = .scaleAspectFit
        errorImageView.tintColor = .white
        errorImageView.isHidden = true
    }

    func addAction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    func updateImageView() {
        switch imageState {
        case let .success(uiImage):
            backgroundColor = .clear
            imageView.image = uiImage
            errorImageView.isHidden = true
            shimmeringView.isHidden = true
            shimmeringView.stopShimmerAnimation()
        case .failure:
            backgroundColor = .systemGray4
            imageView.image = nil
            errorImageView.isHidden = false
            shimmeringView.isHidden = true
            shimmeringView.stopShimmerAnimation()
        case .loading:
            shimmeringView.startShimmerAnimation()
            shimmeringView.isHidden = false
            imageView.image = nil
            errorImageView.isHidden = true
        }
    }

    // MARK: Action

    @objc
    func didTap() {
        guard let uiImage = imageView.image else { return }
        onTapImage?(uiImage)
    }
}

// MARK: - Constants

private extension ReviewPhotoView {

    enum Constants {
        static let errorImageSize: CGFloat = 20
    }
}
