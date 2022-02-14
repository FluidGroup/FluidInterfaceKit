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
    transition: Configuration.Transition = .modalStyle,
    topBar: Configuration.TopBar = .navigation(
      .init(
        displayMode: .automatic,
        usesBodyViewController: true,
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

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
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

  /**
   Configurations for ``FluidViewController``
   
   This struct contains nested structures for creating convenience extensions.
   You may create static members, methods to return constant value.
   
   ```swift
   extension FluidViewController.Configuration {
     static var yourConfiguration: Self { ... }
   }
   
   extension FluidViewController.Configuration.Transition {
     static var yourTransition: Self { ... }
   }
   
   extension FluidViewController.Configuration.TopBar.Navigation {
     static var yourNavigation: Self { ... }
   }
   ```
   */
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

      /**
       push, pop, Edge pan gesture to pop
       */
      public static var navigationStyle: Self {
        return .init(
          addingTransition: .navigationStyle,
          removingTransition: .navigationStyle,
          removingInteraction: .leftToRight
        )
      }

      /**
       like UIModalPresentationStyle.fullScreen
       slide in/out vertically, no gesture
       */
      public static var modalStyle: Self {
        return .init(
          addingTransition: .modalStyle,
          removingTransition: .modalStyle,
          removingInteraction: nil
        )
      }

    }

    public enum TopBar {

      public struct Navigation {

        public enum DisplayMode {
          /// It shows `UINavigationBar` if the target navigation-item has items (title, left items, right items).
          case automatic
          /// It shows always `UINavigationBar`.
          case always
        }

        public var displayMode: DisplayMode

        /// Whether uses navigationItem of the body view controller.
        public var usesBodyViewController: Bool

        public let navigationBarClass: UINavigationBar.Type

        public init(
          displayMode: DisplayMode = .automatic,
          usesBodyViewController: Bool = true,
          navigationBarClass: UINavigationBar.Type = UINavigationBar.self
        ) {
          self.displayMode = displayMode
          self.usesBodyViewController = usesBodyViewController
          self.navigationBarClass = navigationBarClass
        }

      }

      case navigation(Navigation)

      // FIXME: Unimplemented
      case custom
      
      case hidden
      
      public static var navigation: Self {
        .navigation(.init())
      }
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
