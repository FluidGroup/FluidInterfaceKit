import UIKit

/**
 - left
 - main
 - right
 
 - TODO:
  - ViewController life-cycle
 */

@MainActor public protocol FluidStageChildViewController where Self: UIViewController {
  func didSelectPage() -> Void
}

open class FluidStageViewController: UIViewController {
  
  public enum Stage {
    case left
    case main
    case right
  }

  private final class HostingScrollView: UIScrollView {

    override init(frame: CGRect) {
      super.init(frame: frame)
      
      isPagingEnabled = true
      contentInsetAdjustmentBehavior = .never
      showsVerticalScrollIndicator = false
      showsHorizontalScrollIndicator = false
      delaysContentTouches = false
      bounces = false
      
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  private final class InternalView: UIView {

    private let leftSideViewController: FluidStageChildViewController
    private let mainViewController: FluidStageChildViewController
    private let rightSideViewController: FluidStageChildViewController

    private let scrollView: HostingScrollView
    
    private var currentStage: Stage = .main
    
    private var oldBounds: CGRect?
    
    private var offsetObservation: NSKeyValueObservation?

    init(
      scrollView: HostingScrollView,
      leftSideViewController: FluidStageChildViewController,
      mainViewController: FluidStageChildViewController,
      rightSideViewController: FluidStageChildViewController
    ) {
      self.scrollView = scrollView
      self.leftSideViewController = leftSideViewController
      self.mainViewController = mainViewController
      self.rightSideViewController = rightSideViewController

      super.init(frame: .null)
            
      addSubview(scrollView)
      
      let viewControllers = [
        leftSideViewController,
        mainViewController,
        rightSideViewController,
      ]
      
      let stackView = UIStackView(arrangedSubviews: viewControllers.map(\.view))
      scrollView.addSubview(stackView)
      stackView.translatesAutoresizingMaskIntoConstraints = false
            
      NSLayoutConstraint.activate([
        stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
        stackView.rightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.rightAnchor),
        stackView.leftAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leftAnchor),
        stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        
        scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 1)
      ])
            
      for viewController in viewControllers {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          viewController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 1)
        ])
      }
      
      addSubview(scrollView)
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        scrollView.topAnchor.constraint(equalTo: topAnchor),
        scrollView.rightAnchor.constraint(equalTo: rightAnchor),
        scrollView.leftAnchor.constraint(equalTo: leftAnchor),
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
      ])
      
      offsetObservation = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, _ in
        self?.onChangeContentOffset(scrollView: scrollView)
      }
      
      layoutIfNeeded()
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      
      guard oldBounds != bounds else {
        return
      }
      
      oldBounds = bounds
      
      let width = bounds.width
      
      stageToOffset = [
        .left : 0,
        .main: width,
        .right: width * 2
      ]
      
      offsetToStage = stageToOffset.reduce(into: .init(), { partialResult, e in
        partialResult[e.value] = e.key
      })
      
      select(stage: currentStage, animated: false)
      
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
          
    func select(stage: Stage, animated: Bool) {
      
      if currentStage != stage {
        didChangeStage()
      }
      
      currentStage = stage
      scrollView.setContentOffset(.init(x: contentOffsetX(for: stage), y: 0), animated: animated)
    }
    
    private func onChangeContentOffset(scrollView: UIScrollView) {
      
      guard scrollView.isTracking || scrollView.isDecelerating else {
        return
      }
      
      guard let stage = offsetToStage[scrollView.contentOffset.x] else {
        return
      }
      
      guard currentStage != stage else {
        return
      }
      
      currentStage = stage
      
      didChangeStage()
    }
    
    private func didChangeStage() {
      switch currentStage {
      case .main:
        mainViewController.didSelectPage()
      case .left:
        leftSideViewController.didSelectPage()
      case .right:
        rightSideViewController.didSelectPage()
      }
    }
    
    private func contentOffsetX(for stage: Stage) -> CGFloat {
      return stageToOffset[stage]!
    }
    
    private var stageToOffset: [Stage : CGFloat] = [:]
    private var offsetToStage: [CGFloat : Stage] = [:]
        
  }
  
  /**
   A Boolean value that indicates whether the user can scroll to change the stage.
   */
  public var isScrollEnabled: Bool {
    get {
      scrollView.isScrollEnabled
    }
    set {
      scrollView.isScrollEnabled = newValue
    }
  }
  
  private let scrollView: HostingScrollView = .init()

  open override func loadView() {
    let instance = InternalView(
      scrollView: scrollView,
      leftSideViewController: leftSideViewController,
      mainViewController: mainViewController,
      rightSideViewController: rightSideViewController
    )
    self.view = instance
  }

  private let leftSideViewController: FluidStageChildViewController
  private let mainViewController: FluidStageChildViewController
  private let rightSideViewController: FluidStageChildViewController
  
  private var internalView: InternalView {
    view as! InternalView
  }

  public init(
    leftSideViewController: FluidStageChildViewController,
    mainViewController: FluidStageChildViewController,
    rightSideViewController: FluidStageChildViewController
  ) {

    self.leftSideViewController = leftSideViewController
    self.mainViewController = mainViewController
    self.rightSideViewController = rightSideViewController

    super.init(nibName: nil, bundle: nil)

  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    let viewControllers = [
      leftSideViewController,
      mainViewController,
      rightSideViewController,
    ]
    
    for viewController in viewControllers {
      addChild(viewController)
      didMove(toParent: self)
    }
    
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    view.layoutIfNeeded()
  }
  
  public func select(stage: Stage, animated: Bool) {
    internalView.select(stage: stage, animated: animated)
  }
      
}
