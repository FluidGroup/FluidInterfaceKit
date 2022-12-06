
import UIKit

open class FluidSpaceViewController: UIViewController, UIGestureRecognizerDelegate {
  
  private let managedViewControllers: [UIViewController]
   
  public init(
    viewControllers: [UIViewController]
  ) {
    
    self.managedViewControllers = viewControllers
    super.init(nibName: nil, bundle: nil)
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(_onPanGesture(gesture: )))
    view.addGestureRecognizer(panGesture)
        
    managedViewControllers.forEach {
      addChild($0)
      view.addSubview($0.view)
      
      $0.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        $0.view.topAnchor.constraint(equalTo: view.topAnchor),
        $0.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        $0.view.leftAnchor.constraint(equalTo: view.leftAnchor),
        $0.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
      $0.didMove(toParent: self)
    }
        
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Gesture
  
  @objc private func _onPanGesture(gesture: UIPanGestureRecognizer) {
    print("gesture")
  }
  
}
