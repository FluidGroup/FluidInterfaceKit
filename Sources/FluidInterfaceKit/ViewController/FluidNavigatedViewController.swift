import ResultBuilderKit
import UIKit

/// A view controller that extended from ``FluidViewController``.
/// It has ``UINavigationBar`` that working with navigation item of itself or `bodyViewController`.
open class FluidNavigatedViewController: FluidViewController, UINavigationBarDelegate {

  public struct Configuration {

    public struct Transition {

      public var addingTransition: AnyAddingTransition?
      public var removingTransition: AnyRemovingTransition?
      public var removingInteraction: AnyRemovingInteraction?

      public init(
        addingTransition: AnyAddingTransition? = nil,
        removingTransition: AnyRemovingTransition? = nil,
        removingInteraction: AnyRemovingInteraction? = nil
      ) {
        self.addingTransition = addingTransition
        self.removingTransition = removingTransition
        self.removingInteraction = removingInteraction
      }

      public static func navigation() -> Self {
        return .init(
          addingTransition: .navigationIdiom(),
          removingTransition: .navigationIdiom(),
          removingInteraction: .leftToRight()
        )
      }

      public static func modal() -> Self {
        return .init(
          addingTransition: .modalIdiom(),
          removingTransition: .modalIdiom(),
          removingInteraction: nil
        )
      }

    }

    public struct Navigation {

      public enum DisplayMode {
        case hidden
        case automatic
        case always
      }

      public struct BackBarButton {

        private let _make: () -> UIBarButtonItem

        public init(_ make: @escaping () -> UIBarButtonItem) {
          self._make = make
        }

        public func make() -> UIBarButtonItem {
          _make()
        }

        public static var chevronBackward: Self {
          return .init {
            ._fluid_chevronBackward()
          }
        }

        public static var multiply: Self {
          return .init {
            ._fluid_chevronBackward()
          }
        }
      }

      public var displayMode: DisplayMode

      public let backBarButton: BackBarButton?

      public let navigationBarClass: UINavigationBar.Type

      public init(
        displayMode: DisplayMode = .automatic,
        backBarButton: BackBarButton?,
        navigationBarClass: UINavigationBar.Type = UINavigationBar.self
      ) {
        self.displayMode = displayMode
        self.backBarButton = backBarButton
        self.navigationBarClass = navigationBarClass
      }

    }

    public var transition: Transition
    public var navigation: Navigation

    public init(
      transition: Transition,
      navigation: Navigation
    ) {
      self.transition = transition
      self.navigation = navigation
    }

  }

  // MARK: - Properties

  public private(set) var topBar: UIView?

  public var configuration: Configuration {
    didSet {
      configurationDidUpdate(newConfiguration: configuration)
    }
  }

  private var targetNavigationItem: UINavigationItem!
  private var subscriptions: [NSKeyValueObservation] = []

  // MARK: - Initializers

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced later
  public init(
    bodyViewController: UIViewController,
    usesNavigationItemOfBodyViewController: Bool = true,
    configuration: Configuration
  ) {
    self.configuration = configuration
    super.init(
      bodyViewController: bodyViewController,
      addingTransition: configuration.transition.addingTransition,
      removingTransition: configuration.transition.removingTransition,
      removingInteraction: configuration.transition.removingInteraction
    )
    self.targetNavigationItem =
      usesNavigationItemOfBodyViewController ? bodyViewController.navigationItem : navigationItem
  }

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - view: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  ///   - removingInteraction: it can be replaced laterpublic
  public init(
    view: UIView,
    configuration: Configuration
  ) {

    self.configuration = configuration
    super.init(
      view: view,
      addingTransition: configuration.transition.addingTransition,
      removingTransition: configuration.transition.removingTransition,
      removingInteraction: configuration.transition.removingInteraction
    )
    self.targetNavigationItem = navigationItem
  }

  public init(
    configuration: Configuration
  ) {

    self.configuration = configuration
    super.init(
      addingTransition: configuration.transition.addingTransition,
      removingTransition: configuration.transition.removingTransition,
      removingInteraction: configuration.transition.removingInteraction
    )
    self.targetNavigationItem = navigationItem
  }

  deinit {
    subscriptions.forEach {
      $0.invalidate()
    }
  }

  // MARK: - Functions

  open override func viewDidLoad() {
    super.viewDidLoad()

    let navigationBar = configuration.navigation.navigationBarClass.init()

    navigationBar.delegate = self

    view.addSubview(navigationBar)

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
      navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

    if let backBarButtonItem = configuration.navigation.backBarButton?.make() {
      backBarButtonItem.action = #selector(onTapBackButton)
      backBarButtonItem.target = self
      targetNavigationItem.leftBarButtonItem = backBarButtonItem
    }

    navigationBar.pushItem(targetNavigationItem, animated: false)

    observeNavigationItem(navigationItem: targetNavigationItem)

    self.topBar = navigationBar

  }

  open override func viewDidLayoutSubviews() {
    configurationDidUpdate(newConfiguration: configuration)
    if let topBar = topBar {
      view.bringSubviewToFront(topBar)
    }
  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }

  @objc private func onTapBackButton() {
    fluidPop(transition: nil, completion: nil)
  }

  private func configurationDidUpdate(newConfiguration: Configuration) {

    let isNavigationBarHidden: Bool

    switch configuration.navigation.displayMode {
    case .hidden:
      isNavigationBarHidden = true
    case .automatic:

      let flags = [
        (targetNavigationItem.rightBarButtonItems ?? []).isEmpty,
        (targetNavigationItem.leftBarButtonItems ?? []).isEmpty,
        (targetNavigationItem.title ?? "").isEmpty,
        targetNavigationItem.titleView == nil,
      ]
      .compactMap { $0 }

      isNavigationBarHidden = !flags.contains(false)
    case .always:
      isNavigationBarHidden = false
    }

    if let topBar = topBar {
      if isNavigationBarHidden {

        topBar.isHidden = true
        additionalSafeAreaInsets.top = 0

      } else {
        topBar.isHidden = false
        additionalSafeAreaInsets.top = topBar.frame.height
      }

    } else {
      additionalSafeAreaInsets.top = 0
    }

  }

  private func observeNavigationItem(navigationItem: UINavigationItem) {

    let navigationItemDidChange: (UINavigationItem) -> Void = { [weak self] _ in
      guard let self = self else { return }
      self.configurationDidUpdate(newConfiguration: self.configuration)
    }

    subscriptions.forEach {
      $0.invalidate()
    }

    let tokens = buildArray {
      navigationItem.observe(\.titleView, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }

      navigationItem.observe(\.leftBarButtonItem, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }

      navigationItem.observe(\.leftBarButtonItems, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }

      navigationItem.observe(\.rightBarButtonItem, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }

      navigationItem.observe(\.rightBarButtonItems, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }

      navigationItem.observe(\.title, options: [.new]) { item, _ in
        navigationItemDidChange(item)
      }
    }

    subscriptions = tokens

  }

}
