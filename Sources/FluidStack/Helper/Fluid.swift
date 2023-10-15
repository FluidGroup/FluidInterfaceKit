import Foundation
import UIKit
import GeometryKit

/**
 Tools (including not organized.)
 */
public enum Fluid {

  @MainActor
  public static func takeSnapshotVisible(view: UIView) -> UIView {

    let snapshot: UIView

    if view.alpha == 1, view.isHidden == false {
      snapshot = view.snapshotView(afterScreenUpdates: false) ?? UIView()
    } else {
      let alpha = view.layer.opacity
      let isHidden = view.layer.isHidden
      let frame = view.layer.frame

      view.layer.opacity = 1
      view.layer.isHidden = false
      view.layer.frame.origin.x = 10000 // move to out of the screen to avoid blinking
      defer {
        view.layer.opacity = alpha
        view.layer.isHidden = isHidden
        view.layer.frame = frame
      }
      // TODO: result may not render visible content.
      snapshot = view.snapshotView(afterScreenUpdates: false) ?? UIView()
    }

    snapshot.isUserInteractionEnabled = false

    return snapshot
  }
  
  @MainActor
  public static func doIfNotAnimating<View: UIView>(view: View, perform: (View) -> Void) {
    guard hasAnimations(view: view) == false else { return }
    perform(view)
  }

  @MainActor
  public static func hasAnimations(view: UIView) -> Bool {
    return (view.layer.animationKeys() ?? []).count > 0
  }

  @MainActor
  public static func startPropertyAnimators(
    _ animators: [UIViewPropertyAnimator],
    completion: @escaping @MainActor () -> Void
  ) {
    
    let group = DispatchGroup()

    group.enter()

    group.notify(queue: .main) {
      completion()
    }

    for animator in animators {
      group.enter()
      animator.addCompletion { _ in
        group.leave()
      }
    }

    for animator in animators {
      animator.startAnimation()
    }

    group.leave()

  }

  public enum Position {
    case center(of: CGRect)
    case custom(CGPoint)
  }

  @MainActor
  public static func makePropertyAnimatorsForTranformUsingCenter(
    view: UIView,
    duration: TimeInterval,
    position: Position,
    scale: CGPoint,
    velocityForTranslation: CGVector,
    velocityForScaling: CGFloat
  ) -> [UIViewPropertyAnimator] {

    let positionAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: velocityForTranslation
      )
    )

    let scaleAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: CGVector(dx: velocityForScaling, dy: 0)
      )
    )

    scaleAnimator.addAnimations {
      view.transform = .init(scaleX: scale.x, y: scale.y)
    }

    positionAnimator.addAnimations {

      switch position {
      case .center(let rect):

        view.layer.position = .init(x: rect.midX, y: rect.midY)

      case .custom(let value):

        view.layer.position = value
      }

    }

    return [
      positionAnimator,
      scaleAnimator,
    ]
  }

  @MainActor
  public static func setFrameAsIdentity(_ frame: CGRect, for view: UIView) {

    let center = Geometry.center(of: frame)
    
    if view.bounds.size != frame.size {
      view.bounds.size = frame.size
    }
    
    if view.center != center {
      view.center = center
    }

  }
  
  public static func renderOnelineDescription<S>(subject: S, properties: (S) -> [(String, String)]) -> String {
    
    func escapeNewlines(_ value: String) -> String {
      value.replacingOccurrences(of: "\n", with: "\\n")
    }
    
    let propertieLines = properties(subject)
      .map { "\(escapeNewlines($0.0)) = \(escapeNewlines($0.1))" }
    
    if type(of: subject) is AnyClass {
          
      let pointer = Unmanaged.passUnretained(subject as AnyObject).toOpaque()
      
      let hex = String(Int(bitPattern: pointer), radix: 16, uppercase: true)
      
      let values = CollectionOfOne("\(String(reflecting: type(of: subject))): 0x\(hex)") + propertieLines
             
      return "<\(values.joined(separator: "; "))>"
      
    } else {
                         
      let values = CollectionOfOne("\(String(reflecting: type(of: subject)))") + propertieLines
             
      return "<\(values.joined(separator: "; "))>"
    }
  }
  
  /// https://gist.githubusercontent.com/jverkoey/3955471c6670386c54e1d62d9c965b53/raw/b618a3da1dab454195fd9ad66323cf7f36c93639/rubberBand.swift
  public static func rubberBand(value: CGFloat, min: CGFloat, max: CGFloat, bandLength: CGFloat) -> CGFloat {
    if value >= min && value <= max {
      // While we're within range we don't rubber band the value.
      return value
    }
    
    if bandLength <= 0 {
      // The rubber band doesn't exist, return the minimum value so that we stay put.
      return min
    }
    
    let rubberBandCoefficient: CGFloat = 0.55
    // Accepts values from [0...+inf and ensures that f(x) < bandLength for all values.
    let band: (CGFloat) -> CGFloat = { value in
      let demoninator = value * rubberBandCoefficient / bandLength + 1
      return bandLength * (1 - 1 / demoninator)
    }
    if (value > max) {
      return band(value - max) + max;
      
    } else if (value < min) {
      return min - band(min - value);
    }
    
    return value;
  }


}
