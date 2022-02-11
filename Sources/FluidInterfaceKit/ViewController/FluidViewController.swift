import ResultBuilderKit
import UIKit

/// A view controller that extended from ``FluidViewController``.
/// It has ``UINavigationBar`` that working with navigation item of itself or `bodyViewController`.
open class FluidViewController: FluidGestureHandlingViewController, UINavigationBarDelegate {

  // MARK: - Properties

  public private(set) var topBar: UIView?

  private(set) var isTopBarHidden: Bool = false

  public let configuration: Configuration

  private var subscriptions: [NSKeyValueObservation] = []

  private var _onTapBackButton: (FluidViewController) -> Void = { _ in }

  // MARK: - Initializers

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - content:
  ///   - removingInteraction: it can be replaced later
  public init(
    content: FluidWrapperViewController.Content? = nil,
    configuration: Configuration
  ) {
    self.configuration = configuration
    super.init(
      content: content,
      addingTransition: configuration.transition.addingTransition,
      removingTransition: configuration.transition.removingTransition,
      removingInteraction: configuration.transition.removingInteraction
    )
  }

  public init(
    content: FluidWrapperViewController.Content? = nil,
    transition: Configuration.Transition = .modal(),
    topBar: Configuration.TopBar = .navigation(
      .init(
        displayMode: .automatic,
        usesBodyViewController: true,
//        backBarButton: .chevronBackward,
        navigationBarClass: UINavigationBar.self
      )
    )
  ) {
    self.configuration = .init(transition: transition, topBar: topBar)
    super.init(
      content: content,
      addingTransition: configuration.transition.addingTransition,
      removingTransition: configuration.transition.removingTransition,
      removingInteraction: configuration.transition.removingInteraction
    )
  }

  deinit {
    subscriptions.forEach {
      $0.invalidate()
    }
  }

  // MARK: - Functions

  open override func viewDidLoad() {
    super.viewDidLoad()

    switch configuration.topBar {
    case .navigation(let navigation):

      let navigationBar = navigation.navigationBarClass.init()

      navigationBar.delegate = self

      view.addSubview(navigationBar)

      navigationBar.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
      ])

      let targetNavigationItem =
        navigation.usesBodyViewController
        ? (content.bodyViewController?.navigationItem ?? navigationItem) : navigationItem

//      if let backBarButton = navigation.backBarButton {
//
//        let item = backBarButton._make()
//        _onTapBackButton = backBarButton._onTap
//        item.action = #selector(onTapBackButton)
//        item.target = self
//        targetNavigationItem.leftBarButtonItem = item
//
//      }

      navigationBar.pushItem(targetNavigationItem, animated: false)

      subscriptions = Self.observeNavigationItem(navigationItem: targetNavigationItem) {
        [weak self, displayMode = navigation.displayMode] item in

        guard let self = self else { return }

        let isNavigationBarHidden: Bool

        switch displayMode {
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

        if self.isTopBarHidden != isNavigationBarHidden {
          self.isTopBarHidden = isNavigationBarHidden
          self.updateTopBarLayout()
        }

      }

      self.topBar = navigationBar

    case .custom:
      assertionFailure("Unimplemented")
      break
      
    case .hidden:
      break
    }

  }

  open override func viewDidLayoutSubviews() {
    updateTopBarLayout()
  }

  //  open override func didMove(toParent parent: UIViewController?) {
  //    super.didMove(toParent: parent)
  //
  //    if let parent = parent as? FluidStackController {
  //
  //      if parent.configuration.retainsRootViewController {
  //
  //        if parent.stackingViewControllers.count > 1 {
  //
  //        }
  //
  //      } else {
  //
  //        if parent.stackingViewControllers.count > 0 {
  //
  //        }
  //
  //      }
  //
  //    }
  //  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }

  @objc private func onTapBackButton() {
    _onTapBackButton(self)
  }

  private func updateTopBarLayout() {

    guard let topBar = topBar else {
      self.additionalSafeAreaInsets.top = 0
      return
    }

    view.bringSubviewToFront(topBar)

    if isTopBarHidden {

      topBar.isHidden = true
      additionalSafeAreaInsets.top = 0

    } else {
      topBar.isHidden = false
      self.additionalSafeAreaInsets.top = topBar.frame.height
    }

  }

  private static func observeNavigationItem(
    navigationItem: UINavigationItem,
    onUpdated: @escaping (UINavigationItem) -> Void
  ) -> [NSKeyValueObservation] {

    let tokens = buildArray {
      navigationItem.observe(\.titleView, options: [.new]) { item, _ in
        onUpdated(item)
      }

      navigationItem.observe(\.leftBarButtonItems, options: [.new]) { item, _ in
        onUpdated(item)
      }

      navigationItem.observe(\.rightBarButtonItems, options: [.new]) { item, _ in
        onUpdated(item)
      }

      navigationItem.observe(\.title, options: [.new]) { item, _ in
        onUpdated(item)
      }
    }
    
    onUpdated(navigationItem)

    return tokens

  }

}

extension FluidViewController {

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

    public enum TopBar {

      public struct Navigation {

        public enum DisplayMode {
          case automatic
          case always
        }

//        public struct BackBarButton {
//
//          let _make: () -> UIBarButtonItem
//          let _onTap: (FluidViewController) -> Void
//
//          public init(
//            make: @escaping () -> UIBarButtonItem,
//            onTap: @escaping (FluidViewController) -> Void = {
//              $0.fluidPop(transition: nil, completion: nil)
//            }
//          ) {
//            self._make = make
//            self._onTap = onTap
//          }
//
//          public static var chevronBackward: Self {
//            return .init {
//              ._fluid_chevronBackward()
//            }
//          }
//
//          public static var multiply: Self {
//            return .init {
//              ._fluid_chevronBackward()
//            }
//          }
//        }

        public var displayMode: DisplayMode

        public var usesBodyViewController: Bool

//        public let backBarButton: BackBarButton?

        public let navigationBarClass: UINavigationBar.Type

        public init(
          displayMode: DisplayMode = .automatic,
          usesBodyViewController: Bool = true,
//          backBarButton: BackBarButton?,
          navigationBarClass: UINavigationBar.Type = UINavigationBar.self
        ) {
          self.displayMode = displayMode
          self.usesBodyViewController = usesBodyViewController
//          self.backBarButton = backBarButton
          self.navigationBarClass = navigationBarClass
        }

      }

      case navigation(Navigation = .init())

      // FIXME: Unimplemented
      case custom
      
      case hidden
    }

    //    public struct BottomBar {
    //
    //    }

    public let transition: Transition
    public let topBar: TopBar

    public init(
      transition: Transition,
      topBar: TopBar
    ) {
      self.transition = transition
      self.topBar = topBar
    }

  }

}
