//
//  DemoPortalLayer.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/31.
//

import CompositionKit
import Foundation
import MondrianLayout
import UIKit
import FluidStack

/// Demonstrates live portal projections, including one stretched to fill its container.
final class DemoPortalLayerViewController: UIViewController {
  
  private let debuggingLabel = UILabel()
  private let portalView = PortalView()
  private var contentView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
  
    let label = UILabel()
    label.text = "Hello CAPortalLayer"

    let backgroundView = UIView()
    backgroundView.backgroundColor = .systemPink

    UIView.animate(
      withDuration: 0.7,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [
        .repeat,
        .autoreverse,
      ]
    ) {

      backgroundView.backgroundColor = .systemTeal
    } completion: { _ in

    }

    let contentView = AnyUIView { _ in
      label
        .viewBlock
        .padding(8)
        .background(backgroundView)
    }
    
    self.contentView = contentView
        
    debuggingLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
    debuggingLabel.numberOfLines = 0
    
    let portalView2 = PortalView()
    
    let stretchView = StretchedPortalView(portalView: portalView2)
        
    Mondrian.buildSubviews(on: view) {

      ZStackBlock {
        VStackBlock(spacing: 8) {
     
          UILabel()&>.do {
            $0.text = "🔽 original view"
          }

          contentView

          UILabel()&>.do {
            $0.text = "🔽 CAPortalLayer"
          }
          portalView
          stretchView
            .viewBlock
            .height(100)
            .alignSelf(.fill)
          
          StackingSpacer(minLength: 8, expands: false)
          
          HStackBlock(spacing: 4) {
            UIButton.make(title: "hidden") { [unowned self] in
              contentView.isHidden.toggle()
              updateDebuggingInfo()
            }
            UIButton.make(title: "opacity") { [unowned self] in
              contentView.layer.opacity = contentView.layer.opacity == 0 ? 1 : 0
              updateDebuggingInfo()
            }
          }
          
          HStackBlock(spacing: 4) {
            UIButton.make(title: "hidesSourceLayer") { [unowned self] in
              portalView.hidesSourceLayer.toggle()
              updateDebuggingInfo()
            }
            UIButton.make(title: "matchesOpacity") { [unowned self] in
              portalView.matchesOpacity.toggle()
              updateDebuggingInfo()
            }
          }
          
          HStackBlock(spacing: 4) {
            UIButton.make(title: "Add/Remove") { [unowned self] in
              portalView.sourceLayer = portalView.sourceLayer == nil ? contentView.layer : nil
              updateDebuggingInfo()
            }
          }
          
          debuggingLabel
          
          StackingSpacer(minLength: 0)
        }
      }
      .container(respectingSafeAreaEdges: .all)

    }

    Mondrian.layout {
      portalView.mondrian.layout.height(.to(contentView).height)
      portalView.mondrian.layout.width(.to(contentView).width)
      
      portalView2.mondrian.layout.height(.to(contentView).height)
      portalView2.mondrian.layout.width(.to(contentView).width)
    }

    portalView.sourceLayer = contentView.layer
    portalView2.sourceLayer = contentView.layer
    
    updateDebuggingInfo()
  }
  
  private func updateDebuggingInfo() {
    
    debuggingLabel.text = """
    OriginalView
      - isHidden: \(contentView.isHidden)
      - alpha: \(contentView.alpha)
    
    PortalView
      - sourceLayer: \(portalView.sourceLayer.map { $0.debugDescription } ?? "nil")
      - hidesSourceLayer: \(portalView.hidesSourceLayer)
      - matchesOpacity: \(portalView.matchesOpacity)
    """
    
  }
  
}

/// Scales a portal's source-sized bounds to fill this view independently on each axis.
///
/// The embedded portal retains its original bounds so its source projection stays
/// intact. This container observes those bounds and clips the stretched rendering.
fileprivate final class StretchedPortalView: UIView {

  private let portalView: PortalView
  private var boundsObservation: NSKeyValueObservation?

  init(portalView: PortalView) {
    self.portalView = portalView
    super.init(frame: .zero)

    clipsToBounds = true
    addSubview(portalView)

    boundsObservation = portalView.observe(\.bounds) { [weak self] _, _ in
      // UIKit changes bounds on the main actor; KVO delivers synchronously.
      MainActor.assumeIsolated {
        self?.invalidateIntrinsicContentSize()
        self?.setNeedsLayout()
      }
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    boundsObservation?.invalidate()
  }

  override var intrinsicContentSize: CGSize {
    portalView.bounds.size
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    portalView.sizeThatFits(size)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let originalSize = portalView.bounds.size
    guard
      bounds.width > 0,
      bounds.height > 0,
      originalSize.width > 0,
      originalSize.height > 0
    else {
      return
    }

    portalView.transform = CGAffineTransform(
      scaleX: bounds.width / originalSize.width,
      y: bounds.height / originalSize.height
    )
    // Position through center because frame is undefined while a transform is applied.
    portalView.center = CGPoint(x: bounds.midX, y: bounds.midY)
  }
}
