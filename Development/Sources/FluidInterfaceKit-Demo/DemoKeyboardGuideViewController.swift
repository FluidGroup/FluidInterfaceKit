import MondrianLayout
import FluidKeyboardSupport

@available(iOS 15, *)
final class DemoKeyboardGuideViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let scrollView = UIScrollView()

    let contentView = UIView()
    contentView.backgroundColor = .systemPurple

    scrollView.addSubview(contentView)

    let textField = UITextField()

    textField.backgroundColor = .systemBackground
    textField.placeholder = "Type something"
    textField.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(textField)

    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
      textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      textField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
    ])


    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
    ])

    Mondrian.layout {
      contentView.mondrian.layout.height(1000)
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        scrollView
      }
      .padding(.bottom, 200)
    }

    scrollView.setContentInsetAdjustmentForKeyboard(isActive: true)
    scrollView.setKeyboardSwipeDownOffscreenGesture(isActive: true)
  }

  private var observation: KeyboardObservation?

}
