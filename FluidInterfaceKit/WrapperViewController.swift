
import UIKit

open class WrapperViewController: UIViewController {

  public let bodyViewController: UIViewController?
  private let customView: UIView?

  public override var childForStatusBarStyle: UIViewController? {
    return bodyViewController
  }

  public override var childForStatusBarHidden: UIViewController? {
    return bodyViewController
  }

  public init(
    bodyViewController: UIViewController
  ) {

    self.bodyViewController = bodyViewController
    self.customView = nil
    super.init(nibName: nil, bundle: nil)
  }

  public init(
    view: UIView
  ) {

    self.bodyViewController = nil
    self.customView = view
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    if let customView = customView {
      view = customView
    } else {
      super.loadView()
    }
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    if let bodyViewController = bodyViewController {
      addChild(bodyViewController)
      view.addSubview(bodyViewController.view)
      bodyViewController.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        bodyViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        bodyViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        bodyViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
        bodyViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
      bodyViewController.didMove(toParent: self)
    }

  }

}
