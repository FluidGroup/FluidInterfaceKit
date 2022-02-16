import ResultBuilderKit
import UIKit

/**
 A view controller that can display on ``FluidStackController``.   
 */
open class FluidViewController: FluidGestureHandlingViewController, UINavigationBarDelegate {

  private struct State: Equatable {

    var isTopBarHidden: Bool = false

    var isTopBarAvailable: Bool = false

    var viewBounds: CGRect = .zero

    var createdTopBar: UIView?
  }

  // MARK: - Properties

  public var topBar: UIView? {
    state.createdTopBar
  }

  public var isTopBarHidden: Bool {
    get { state.isTopBarHidden }
    set { state.isTopBarHidden = newValue }
  }

  public let configuration: Configuration

  private var subscriptions: [NSKeyValueObservation] = []

  private var state: State = .init() {
    didSet {
      guard state != oldValue else { return }
      stateDidUpdate(state: state, previous: oldValue)
    }
  }

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
  
  @objc
  open func triggerFluidPop() {
    fluidPop(transition: nil)
  }
    
  open func willTransition(with relation: StackingRelation) {
    
    assert(isViewLoaded, "library is broke.")
    
    switch configuration.topBar {
    case .navigation(let navigation):
      navigation._activityHandler(.willTransition(self, relation, topBar as! UINavigationBar))
    case .custom:
      break
    case .hidden:
      break
    }
    
    // setting transitions and interactions accroding to the relation
    // TODO: Make here letting the consumer passing as a parameter.
    do {
      switch relation {
      case .modality:
        
        addingTransition = addingTransition ?? .modalStyle
        removingTransition = removingTransition ?? .modalStyle
        
      case .hierarchicalNavigation:
        
        addingTransition = addingTransition ?? .navigationStyle
        removingTransition = removingTransition ?? .navigationStyle
        removingInteraction = removingInteraction ?? .leftToRight
        
      default:
        break
      }
    }
  }

  open override func viewDidLoad() {
    super.viewDidLoad()
    
    // neccessary for using standalone UINavigationBar top-attached.
    // it's weird, specifying topAttached, and setting additionalSafeArea, _UIBarBackground will be extended too long.
    view.clipsToBounds = true

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

      navigation._activityHandler(.didLoad(self, navigationBar))

      // Triggers update
      state.createdTopBar = navigationBar

      subscriptions = Self.observeNavigationItem(
        navigationItem: targetNavigationItem
      ) { [weak self, displayMode = navigation.displayMode] item in

        guard let self = self else { return }

        let isNavigationBarAvailable: Bool

        switch displayMode {
        case .automatic:

          let flags = [
            (targetNavigationItem.rightBarButtonItems ?? []).isEmpty,
            (targetNavigationItem.leftBarButtonItems ?? []).isEmpty,
            (targetNavigationItem.title ?? "").isEmpty,
            targetNavigationItem.titleView == nil,
          ]
          .compactMap { $0 }

          isNavigationBarAvailable = flags.contains(false)

        case .always:

          isNavigationBarAvailable = true
        }
        
        if targetNavigationItem.fluidIsEnabled {
          self.state.isTopBarAvailable = isNavigationBarAvailable
        } else {
          self.state.isTopBarAvailable = false
        }

      }

    case .custom:
      assertionFailure("Unimplemented")
      break

    case .hidden:
      self.state.isTopBarAvailable = false
    }

  }

  open override func viewDidLayoutSubviews() {

    super.viewDidLayoutSubviews()

    if let topBar = topBar {
      view.bringSubviewToFront(topBar)
    }

    state.viewBounds = view.bounds

  }

  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }

  private func stateDidUpdate(state: State, previous: State) {

    if let topBar = topBar {

      if !state.isTopBarHidden && state.isTopBarAvailable {
        topBar.isHidden = false
        additionalSafeAreaInsets.top = topBar.frame.height
      } else {
        topBar.isHidden = true
        additionalSafeAreaInsets.top = 0
      }

    } else {
      additionalSafeAreaInsets.top = 0
    }

  }

  private static func observeNavigationItem(
    navigationItem: UINavigationItem,
    onUpdated: @escaping (UINavigationItem) -> Void
  ) -> [NSKeyValueObservation] {

    let tokens = buildArray {
      navigationItem.observe(\.fluidIsEnabled, options: [.new]) { item, _ in
        onUpdated(item)
      }
      
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
        
        public enum Activity<NavigationBar: UINavigationBar> {
          case didLoad(FluidViewController, NavigationBar)
          case willTransition(FluidViewController, StackingRelation, NavigationBar)
        }

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

        let _activityHandler: (Activity<UINavigationBar>) -> Void

        /// Initializer
        ///
        /// - Parameters:
        ///   - updateNavigationBar: A closure to update the navigation bar with the owner.
        public init<NavigationBar: UINavigationBar>(
          displayMode: DisplayMode = .automatic,
          usesBodyViewController: Bool = true,
          navigationBarClass: NavigationBar.Type,
          activityHandler: @escaping (Activity<NavigationBar>) -> Void = { _ in }
        ) {
          self.displayMode = displayMode
          self.usesBodyViewController = usesBodyViewController
          self.navigationBarClass = navigationBarClass
          self._activityHandler = { activity in
            switch activity {
            case .didLoad(let controller, let navigationBar):
              activityHandler(.didLoad(controller, navigationBar as! NavigationBar))
            case .willTransition(let controller, let relation, let navigationBar):
              activityHandler(.willTransition(controller, relation, navigationBar as! NavigationBar))
            }
          }
        }

      }

      case navigation(Navigation)

      // FIXME: Unimplemented
      case custom

      case hidden

      public static var navigation: Self {
        .navigation(.init(navigationBarClass: UINavigationBar.self))
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
