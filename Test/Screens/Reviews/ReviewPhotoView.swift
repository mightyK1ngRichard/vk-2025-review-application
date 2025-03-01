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
        case let .success(uiImage):
            backgroundColor = .clear
            imageView.image = uiImage
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
