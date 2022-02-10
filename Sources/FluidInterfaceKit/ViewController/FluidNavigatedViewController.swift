import UIKit

/// A view controller that extended from ``FluidViewController``.
/// It has ``UINavigationBar`` that working with navigation item of itself or `bodyViewController`.
open class FluidNavigatedViewController: FluidViewController, UINavigationBarDelegate {

  public struct Configuration {

    public var addingTransition: AnyAddingTransition?
    public var removingTransition: AnyRemovingTransition?
    public var removingInteraction: AnyRemovingInteraction?

    public var makeBackbarButtonItem: () -> UIBarButtonItem
    public var makeNavigationBar: () -> UINavigationBar

    public init(
      addingTransition: AnyAddingTransition? = .navigationIdiom(),
      removingTransition: AnyRemovingTransition? = .navigationIdiom(),
      removingInteraction: AnyRemovingInteraction? = nil,
      makeNavigationBar: @escaping () -> UINavigationBar = { UINavigationBar() },
      makeBackbarButtonItem: @escaping () -> UIBarButtonItem = { ._fluid_backButton() }
    ) {
      self.addingTransition = addingTransition
      self.removingTransition = removingTransition
      self.removingInteraction = removingInteraction
      self.makeNavigationBar = makeNavigationBar
      self.makeBackbarButtonItem = makeBackbarButtonItem
    }

  }

  public let navigationBar: UINavigationBar
  public let configuration: Configuration

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced later
  public init(
    bodyViewController: UIViewController,
    configuration: Configuration = .init()
  ) {
    self.configuration = configuration
    self.navigationBar = configuration.makeNavigationBar()
    super.init(
      bodyViewController: bodyViewController,
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
    )
  }

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - view: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced laterpublic
  public init(
    view: UIView,
    configuration: Configuration = .init()
  ) {

    self.configuration = configuration
    self.navigationBar = configuration.makeNavigationBar()
    super.init(
      view: view,
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
    )
  }

  public init(
    configuration: Configuration = .init()
  ) {

    self.configuration = configuration
    self.navigationBar = configuration.makeNavigationBar()
    super.init(
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
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

  open override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    if let parent = parent as? FluidStackController {

      if parent.stackingViewControllers.count > 1 {

        let targetNavigationItem = navigationBar.topItem
        let backBarButtonItem = configuration.makeBackbarButtonItem()
        backBarButtonItem.action = #selector(onTapBackButton)
        backBarButtonItem.target = self
        targetNavigationItem?.leftBarButtonItem = backBarButtonItem
      }
    }
  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }

  @objc private func onTapBackButton() {
    fluidPop(transition: nil, completion: nil)
  }

}
