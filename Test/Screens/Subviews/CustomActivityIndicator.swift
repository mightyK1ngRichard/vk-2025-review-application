import UIKit

final class CustomActivityIndicator: UIView {

    private let circleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayer() {
        let radius: CGFloat = min(bounds.width, bounds.height) / 2
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi * 3 / 2,
            clockwise: true
        )

        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor.systemBlue.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = radius / 5.5
        circleLayer.lineCap = .round
        layer.addSublayer(circleLayer)
    }

    func startAnimating() {
        circleLayer.isHidden = false
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2.0 * .pi
        rotationAnimation.duration = CFTimeInterval(1)
        rotationAnimation.repeatCount = .infinity
        layer.add(rotationAnimation, forKey: "rotation")
    }

    func stopAnimating() {
        layer.removeAnimation(forKey: "rotation")
        circleLayer.isHidden = true
    }
}
