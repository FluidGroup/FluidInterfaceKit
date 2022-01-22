#if false

import UIKit

private var key: Void?

final class BlurLayer: CALayer {

  @objc var blurRadius: CGFloat = 0 {
    didSet {
      setNeedsDisplay()
    }
  }

  override class func needsDisplay(forKey key: String) -> Bool {
    if key == "blurRadius" {
      return false
    }
    return super.needsDisplay(forKey: key)
  }

  override func action(forKey event: String) -> CAAction? {
    let action = super.action(forKey: event)
    if event == "blurRadius" {
      let animation = CABasicAnimation(keyPath: "blurRadius")
      animation.fromValue = 0
      animation.toValue = 100
      animation.duration = 2
      return animation
    }
    return action
  }

  override func draw(in ctx: CGContext) {
    super.draw(in: ctx)

    let radius = blurRadius

    if radius > 0 {
      if let wrapper = blurFilterWrapper {
        wrapper.radius = radius
      } else {
        blurFilterWrapper = makeBlurFilter()
        blurFilterWrapper!.radius = radius
      }
    } else {
      blurFilterWrapper = nil
    }
    
  }
  
  override func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)

    if key == "blurRadius" {
      let radius = blurRadius

      if radius > 0 {
        if let wrapper = blurFilterWrapper {
          wrapper.radius = radius
        } else {
          blurFilterWrapper = makeBlurFilter()
          blurFilterWrapper!.radius = radius
        }
      } else {
        blurFilterWrapper = nil
      }

    }
  }

  private var blurFilterWrapper: BlurFilterWrapper? {
    get {
      objc_getAssociatedObject(self, &key) as? BlurFilterWrapper
    }
    set {
      objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_COPY)
      if let newValue = newValue {
        newValue.apply(to: self)
      } else {
        setValue([], forKey: encodeText("gjmufst", -1))
      }
    }
  }

  public func makeBlurAction(from fromRadius: CGFloat) -> CAAnimation? {

    guard let blurFilterWrapper = blurFilterWrapper else {
      return nil
    }

    let animation = CABasicAnimation(keyPath: "blurRadius")
    animation.fromValue = fromRadius
    animation.toValue = blurFilterWrapper.radius
    animation.duration = 0.3
    animation.fillMode = .both
    animation.isRemovedOnCompletion = true
    animation.isAdditive = true

    return animation
  }

}

struct BlurFilterWrapper {

  let filter: NSObject

  var radius: CGFloat {
    get {
      filter.value(forKey: encodeText("joqvuSbejvt", -1)) as? CGFloat ?? 0
    }
    nonmutating set {
      filter.setValue(newValue, forKey: encodeText("joqvuSbejvt", -1))
    }
  }

  init(filter: NSObject) {
    self.filter = filter
  }

  func apply(to layer: CALayer) {
    layer.setValue([filter], forKey: encodeText("gjmufst", -1))
  }

}

private let blurFilter: NSObject? = {

  let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

  var filters: [NSObject] = []

  let blurFilter = visualEffectView.subviews
    .compactMap {
      ($0.layer.value(forKey: encodeText("gjmufst", -1)) as? [Any])?.compactMap {
        ($0 as? NSObject)?.mutableCopy() as? NSObject
      }
    }
    .flatMap { $0 }
    .filter { $0.value(forKey: "name") as! NSString == encodeText("hbvttjboCmvs", -1) as NSString }
    .first

  blurFilter?.perform(#selector(CIFilter.setDefaults))
  return blurFilter
}()

private func makeBlurFilter() -> BlurFilterWrapper? {

  guard let filter = blurFilter else {
    return nil
  }

  let copiedBlurFilter = filter.mutableCopy() as! NSObject

  return .init(filter: copiedBlurFilter)
}

private func encodeText(_ string: String, _ key: Int) -> String {
  var result = ""
  for c in string.unicodeScalars {
    result.append(Character(UnicodeScalar(UInt32(Int(c.value) + key))!))
  }
  return result
}

#endif
