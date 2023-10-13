import FluidSnackbar
import MondrianLayout
import UIKit

final class DemoSnackbarView: SnackbarPlainBase {

  let label = UILabel()

  init(text: String) {
    super.init()

    contentView.addSubview(label)
    label.text = text
    Mondrian.layout {
      label.mondrian.layout.edges(.toSuperview, .exact(8))
    }
    label.font = UIFont.preferredFont(forTextStyle: .title2)
  }
}
