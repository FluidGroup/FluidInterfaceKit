
import UIKit

public enum ViewControllerLifecycleEvent {
  case viewDidLoad
  case viewWillAppear
  case viewDidAppear
  case viewWillDisappear
  case viewDidDisappear
}

open class FluidWrapperViewController: UIViewController {
    
  public struct Content: Equatable {
    
    /**
     View Controller to embed
     */
    public var bodyViewController: UIViewController?
    
    /**
     View to use as root view
     */
    public var view: UIView?
    
    public init(bodyViewController: UIViewController? = nil, view: UIView? = nil) {
      self.bodyViewController = bodyViewController
      self.view = view
    }
    
  }
  
  public let content: Content

  public override var childForStatusBarStyle: UIViewController? {
    return content.bodyViewController
  }

  public override var childForStatusBarHidden: UIViewController? {
    return content.bodyViewController
  }
  
  public var lifecycleEventHandler: (FluidWrapperViewController, ViewControllerLifecycleEvent) -> Void = { _, _  in }

  public init(content: Content?) {

    self.content = content ?? .init(bodyViewController: nil, view: nil)
    
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func loadView() {
    if let customView = content.view {
      view = customView
    } else {
      super.loadView()
    }
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    // setting up key commands
    do {

      if globalConfiguration.escKeyToPop {

        addKeyCommand(
          UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(actionForKeycommand)
          )
        )
        
      }
    }
    
    lifecycleEventHandler(self, .viewDidLoad)

    if let bodyViewController = content.bodyViewController {
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
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    lifecycleEventHandler(self, .viewWillAppear)
  }
  
  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    lifecycleEventHandler(self, .viewDidAppear)
  }
  
  open override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    lifecycleEventHandler(self, .viewWillDisappear)
  }
  
  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    lifecycleEventHandler(self, .viewDidDisappear)
  }

  @objc
  private func actionForKeycommand() {
    fluidPop()
  }

  open override var canBecomeFirstResponder: Bool {
    return true
  }


}
