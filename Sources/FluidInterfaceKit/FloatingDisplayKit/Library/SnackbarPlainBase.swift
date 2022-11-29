
import UIKit

open class SnackbarPlainBase : SnackbarDraggableBase {

  // MARK: - Properties

  private let shadowLayer = CALayer()

  // MARK: - Initializers

  public init() {
    super.init(topMargin: 0)
  }

  open override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)

    shadowLayer.frame = contentView.layer.frame
    shadowLayer.shadowPath = UIBezierPath(roundedRect: contentView.layer.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
  }

  open override func setupView() {
    super.setupView()

    self.layer.insertSublayer(shadowLayer, at: 0)

    backgroundColor = .clear
    contentView.backgroundColor = .white
    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 8

    shadowLayer.masksToBounds = false
    shadowLayer.shadowColor = UIColor(white: 0, alpha: 0.1).cgColor
    shadowLayer.shadowOpacity = 1
    shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
    shadowLayer.shadowRadius = 3
  }

}
