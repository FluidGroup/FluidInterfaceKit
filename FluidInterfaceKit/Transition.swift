import UIKit
import MatchedTransition


func makeCGAffineTransform(from: CGRect, to: CGRect) -> CGAffineTransform {

  return .init(
    a: to.width / from.width,
    b: 0,
    c: 0,
    d: to.height / from.height,
    tx: to.midX - from.midX,
    ty: to.midY - from.midY
  )
}

func makeTranslation(from: CGRect, to: CGRect) -> (center: CGPoint, scale: CGSize) {

  return (
    center: to.center,
    scale: .init(width: to.width / from.width, height: to.height / from.height)
  )

}

extension CGRect {

  var center: CGPoint {
    return CGPoint(x: self.midX, y: self.midY)
  }
}
