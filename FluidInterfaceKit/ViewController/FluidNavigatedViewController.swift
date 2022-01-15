import UIKit

open class FluidNavigatedViewController: FluidViewController, UINavigationBarDelegate {

  public let navigationBar: UINavigationBar

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - interaction: it can be replaced later
  public init(
    bodyViewController: UIViewController,
    transition: TransitionPair,
    interactionToRemove: AnyRemovingInteraction? = nil,
    navigatonBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {
    self.navigationBar = navigatonBarClass.init()
    super.init(bodyViewController: bodyViewController, transition: transition, interactionToRemove: interactionToRemove)
  }

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - view: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - interaction: it can be replaced laterpublic
  public init(
    view: UIView,
    transition: TransitionPair,
    interaction: AnyRemovingInteraction? = nil,
    navigatonBarClass: UINavigationBar.Type = UINavigationBar.self
  ) {

    self.navigationBar = navigatonBarClass.init()
    super.init(view: view, transition: transition, interaction: interaction)
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
