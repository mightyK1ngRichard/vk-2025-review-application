import UIKit

final class ZoomableImageViewController: UIViewController, UIScrollViewDelegate {

    // MARK: UI Subviews

    private let overlayView = UIView()
    private let scrollView = UIScrollView()
    private let closeButton = CloseButton(type: .system)
    private let imageView = UIImageView()

    // MARK: Life cycle

    init(uiImage: UIImage) {
        imageView.image = uiImage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) {
            self.scrollView.alpha = 1
            self.imageView.alpha = 1
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = scrollView.bounds
        closeButton.frame = CGRect(
            x: view.bounds.width - Constants.closeButtonSize - Constants.closeButtonInset,
            y: view.safeAreaInsets.top + Constants.closeButtonInset,
            width: Constants.closeButtonSize,
            height: Constants.closeButtonSize
        )
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomableImageViewController {

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK: - Private

private extension ZoomableImageViewController {

    func setup() {
        setScrollView()
        setImageView()
        setCloseButton()
        addAction()
    }

    func setScrollView() {
        scrollView.alpha = 0
        imageView.alpha = 0
        scrollView.backgroundColor = .black.withAlphaComponent(0.85)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }

    func setImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
    }

    func setCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeOverlay), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    func addAction() {
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleDoubleTap)
        )
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
    }

    func centerImage() {
        let boundsSize = view.bounds.size
        var frameToCenter = imageView.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        imageView.frame = frameToCenter
    }

    func zoomRect(for scale: CGFloat, center: CGPoint) -> CGRect {
        let size = CGSize(
            width: view.bounds.width / scale,
            height: view.bounds.height / scale
        )
        let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        return CGRect(origin: origin, size: size)
    }

    // MARK: Actions

    @objc
    func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let scale = scrollView.zoomScale == 1.0 ? 2.5 : 1.0
        let point = gesture.location(in: imageView)
        let zoomRect = zoomRect(for: scale, center: point)
        scrollView.zoom(to: zoomRect, animated: true)
    }

    @objc
    func closeOverlay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton.alpha = 0
            self.scrollView.alpha = 0
            self.imageView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - CloseButton

private extension ZoomableImageViewController {

    class CloseButton: UIButton {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let largerArea = CGRect(
                x: -20,
                y: -20,
                width: bounds.width + 40,
                height: bounds.height + 40
            )
            return largerArea.contains(point) ? self : nil
        }
    }
}

// MARK: - Constants

private extension ZoomableImageViewController {

    enum Constants {
        static let closeButtonSize: CGFloat = 30
        static let closeButtonInset: CGFloat = 16
    }
}
