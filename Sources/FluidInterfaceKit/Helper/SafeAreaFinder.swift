//
//  File.swift
//  
//
//  Created by Antoine Marandon on 28/11/2022.
//

import UIKit

/// This class is a helper for finding current safe area insets when they are not available in the direct view hierarchy
public final class SafeAreaFinder: NSObject {

  public static let notificationName = Notification.Name(rawValue: "app.muukii.fluid.SafeAreaInsetsManager")

  public static let shared = SafeAreaFinder()

  private var currentInsets: UIEdgeInsets? = nil

  private var referenceCounter: Int = 0 {
    didSet {
      if referenceCounter > 0 {
        currentDisplayLink.isPaused = false
      } else {
        currentDisplayLink.isPaused = true
      }
    }
  }

  private var currentDisplayLink: CADisplayLink!

  private override init() {

    super.init()

    currentDisplayLink = .init(target: self, selector: #selector(handle))
    currentDisplayLink.preferredFramesPerSecond = 1
    currentDisplayLink.add(to: .main, forMode: .default)
    currentDisplayLink.isPaused = true
  }

  public func request() {
    handle()
  }

  public func start() {
    currentInsets = nil
    referenceCounter += 1
    request()
  }

  public func pause() {
    referenceCounter -= 1
  }

  deinit {
    currentDisplayLink.isPaused = true
    currentDisplayLink.invalidate()
  }

  @objc private dynamic func handle() {
    guard let window = UIApplication.shared.delegate?.window ?? nil else {
      return
    }
    _handle(in: window)
  }

  private func _handle(in window: UIWindow) {

    var maximumInsets: UIEdgeInsets = .zero

    let windowSize = window.bounds.size

    func recursive(view: UIView) {

      let frame = view.convert(view.bounds, to: window)
      var insets = view.safeAreaInsets

      guard insets != .zero else {
        return
      }

      if insets.top > 0 {
        insets.top += frame.origin.y
      }

      if insets.left > 0 {
        insets.left += frame.origin.x
      }

      if insets.right > 0 {
        insets.right += windowSize.width - frame.maxX
      }

      if insets.bottom > 0 {
        insets.bottom += windowSize.height - frame.maxY
      }

      var accumulated = false

      if insets.top >= maximumInsets.top {
        maximumInsets.top = insets.top
        accumulated = true
      }

      if insets.left >= maximumInsets.left {
        maximumInsets.left = insets.left
        accumulated = true
      }

      if insets.right >= maximumInsets.right {
        maximumInsets.right = insets.right
        accumulated = true
      }

      if insets.bottom >= maximumInsets.bottom {
        maximumInsets.bottom = insets.bottom
        accumulated = true
      }

      guard view is UIScrollView == false else {
        return
      }

      if accumulated {
        for view in view.subviews {
          recursive(view: view)
        }
      }
    }

    recursive(view: window)

    if currentInsets != maximumInsets {
      currentInsets = maximumInsets
      NotificationCenter.default.post(name: Self.notificationName, object: maximumInsets)
    }
  }

}
