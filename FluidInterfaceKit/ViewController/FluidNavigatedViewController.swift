import UIKit

open class FluidNavigatedViewController: FluidViewController, UINavigationBarDelegate {

  public let navigationBar: UINavigationBar

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced later
  public init(
    bodyViewController: UIViewController,
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?,
    removingInteraction: AnyRemovingInteraction?,
    navigatonBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {
    self.navigationBar = navigatonBarClass.init()
    super.init(
      bodyViewController: bodyViewController,
      addingTransition: addingTransition,
      removingTransition: removingTransition,
      removingInteraction: removingInteraction
    )
  }

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - view: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced laterpublic
  public init(
    view: UIView,
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?,
    removingInteraction: AnyRemovingInteraction?,
    navigatonBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {

    self.navigationBar = navigatonBarClass.init()
    super.init(
      view: view,
      addingTransition: addingTransition,
      removingTransition: removingTransition,
      removingInteraction: removingInteraction
    )
  }

  public init(
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?,
    removingInteraction: AnyRemovingInteraction?,
    navigatonBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {

    self.navigationBar = navigatonBarClass.init()
    super.init(
      addingTransition: addingTransition,
      removingTransition: removingTransition,
      removingInteraction: removingInteraction
    )
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    navigationBar.delegate = self

    view.addSubview(navigationBar)

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
      navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

    if let bodyViewController = bodyViewController {
      navigationBar.pushItem(bodyViewController.navigationItem, animated: false)
    } else {
      navigationBar.pushItem(navigationItem, animated: false)
    }
  }

  open override func viewDidLayoutSubviews() {
    additionalSafeAreaInsets.top = navigationBar.frame.height
    view.bringSubviewToFront(navigationBar)
  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}
