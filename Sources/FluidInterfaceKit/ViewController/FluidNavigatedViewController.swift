import UIKit
import ResultBuilderKit

/// A view controller that extended from ``FluidViewController``.
/// It has ``UINavigationBar`` that working with navigation item of itself or `bodyViewController`.
open class FluidNavigatedViewController: FluidViewController, UINavigationBarDelegate {

  public struct Configuration {
    
    public enum NavigationBarDisplayMode {
      case hidden
      case automatic
      case always
    }
               
    public var addingTransition: AnyAddingTransition?
    public var removingTransition: AnyRemovingTransition?
    public var removingInteraction: AnyRemovingInteraction?
    
    public var navigationBarBehavior: NavigationBarDisplayMode

    public var makeBackBarButtonItem: () -> UIBarButtonItem
    public var makeNavigationBar: () -> UINavigationBar

    public init(
      addingTransition: AnyAddingTransition? = .navigationIdiom(),
      removingTransition: AnyRemovingTransition? = .navigationIdiom(),
      removingInteraction: AnyRemovingInteraction? = nil,
      navigationBarDisplayMode: NavigationBarDisplayMode = .automatic,
      makeNavigationBar: @escaping () -> UINavigationBar = { UINavigationBar() },
      makeBackBarButtonItem: @escaping () -> UIBarButtonItem = { ._fluid_backButton() }
    ) {
      self.addingTransition = addingTransition
      self.removingTransition = removingTransition
      self.removingInteraction = removingInteraction
      self.navigationBarBehavior = navigationBarDisplayMode
      self.makeNavigationBar = makeNavigationBar
      self.makeBackBarButtonItem = makeBackBarButtonItem
    }

  }
  
  // MARK: - Properties

  public private(set) lazy var navigationBar: UINavigationBar = {
    configuration.makeNavigationBar()
  }()
  
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
    configuration: Configuration = .init()
  ) {
    self.configuration = configuration
    super.init(
      bodyViewController: bodyViewController,
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
    )
    self.targetNavigationItem = usesNavigationItemOfBodyViewController ? bodyViewController.navigationItem : navigationItem
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
    super.init(
      view: view,
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
    )
    self.targetNavigationItem = navigationItem
  }

  public init(
    configuration: Configuration = .init()
  ) {

    self.configuration = configuration
    super.init(
      addingTransition: configuration.addingTransition,
      removingTransition: configuration.removingTransition,
      removingInteraction: configuration.removingInteraction
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

    navigationBar.delegate = self

    view.addSubview(navigationBar)

    navigationBar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
      navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
    ])

    navigationBar.pushItem(targetNavigationItem, animated: false)
    
    observeNavigationItem(navigationItem: targetNavigationItem)
  }
  
  open override func viewDidLayoutSubviews() {
    configurationDidUpdate(newConfiguration: configuration)
    view.bringSubviewToFront(navigationBar)
  }

  open override func didMove(toParent parent: UIViewController?) {
    super.didMove(toParent: parent)

    if let parent = parent as? FluidStackController {

      if parent.stackingViewControllers.count > 1 {

        let targetNavigationItem = navigationBar.topItem
        let backBarButtonItem = configuration.makeBackBarButtonItem()
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
  
  private func configurationDidUpdate(newConfiguration: Configuration) {
    
    let isNavigationBarHidden: Bool
    
    switch configuration.navigationBarBehavior {
    case .hidden:
      isNavigationBarHidden = true
    case .automatic:
      
      let flags = [
        (targetNavigationItem.rightBarButtonItems ?? []).isEmpty,
        (targetNavigationItem.leftBarButtonItems ?? []).isEmpty,
        (targetNavigationItem.title ?? "").isEmpty,
        targetNavigationItem.titleView == nil
      ]
        .compactMap { $0 }
      
      isNavigationBarHidden = !flags.contains(false)
    case .always:
      isNavigationBarHidden = false
    }
    
    if isNavigationBarHidden {
      
      navigationBar.isHidden = true
      additionalSafeAreaInsets.top = 0
      
    } else {
      navigationBar.isHidden = false
      additionalSafeAreaInsets.top = navigationBar.frame.height
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
      
      navigationItem.observe(\.title, options: [.new]){ item, _ in
        navigationItemDidChange(item)
      }
    }
    
    subscriptions = tokens
    
  }

}
