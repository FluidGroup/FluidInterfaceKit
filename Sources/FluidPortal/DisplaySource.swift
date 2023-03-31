import class UIKit.UIView
import class QuartzCore.CALayer

public enum DisplaySource: Hashable {
  case view(UIView)
  case layer(CALayer)
}
