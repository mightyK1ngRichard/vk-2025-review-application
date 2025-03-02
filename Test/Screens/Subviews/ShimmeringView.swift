import UIKit

final class ShimmerView: UIView {

    private var gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmerEffect()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmerEffect()
    }

    private func setupShimmerEffect() {
        gradientLayer.colors = [
            UIColor.shimmiring.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.shimmiring.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.addSublayer(gradientLayer)
    }

    func startShimmerAnimation() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.autoreverses = false
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }

    func stopShimmerAnimation() {
        gradientLayer.removeAnimation(forKey: "shimmerAnimation")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
