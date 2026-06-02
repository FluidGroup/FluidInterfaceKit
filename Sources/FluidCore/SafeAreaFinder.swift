//
//  File.swift
//  
//
//  Created by Antoine Marandon on 28/11/2022.
//

import UIKit

/// This class is a helper for finding current safe area insets when they are not available in the direct view hierarchy
@MainActor
public final class SafeAreaFinder: NSObject {

  public static let notificationName = Notification.Name(rawValue: "app.muukii.fluid.SafeAreaInsetsManager")

  @available(iOS 13.0, *)
  public weak var windowScene: UIWindowScene?

  private var currentInsets: UIEdgeInsets? = nil

  private var isRunning: Bool = false

  private nonisolated(unsafe) var currentDisplayLink: CADisplayLink?

  @available(iOS 13.0, *)
  public init(windowScene: UIWindowScene?) {
    self.windowScene = windowScene

    super.init()
  }

  private func setUpDisplayLink() {
    guard currentDisplayLink == nil else {
      return
    }

    currentDisplayLink = .init(target: self, selector: #selector(handle))
    currentDisplayLink?.preferredFramesPerSecond = 1
    currentDisplayLink?.add(to: .main, forMode: .default)
    currentDisplayLink?.isPaused = false
  }

  public func request() {
    currentInsets = nil
    handle()
  }

  public func start() {
    guard isRunning == false else {
      request()
      return
    }

    isRunning = true
    setUpDisplayLink()
    request()
  }

  /// Stops polling and releases the display link so the finder can deallocate when its owner goes away.
  public func stop() {
    guard isRunning || currentDisplayLink != nil else {
      return
    }

    isRunning = false
    currentInsets = nil
    currentDisplayLink?.invalidate()
    currentDisplayLink = nil
  }

  /// Stops polling. Kept as a compatibility alias for older callers that used the reference-counted API.
  public func pause() {
    stop()
  }

  deinit {
    currentDisplayLink?.invalidate()
  }

  @objc private dynamic func handle() {

    guard let windowScene else {
      return
    }

    guard let window = windowScene.windows.first(where: \.isKeyWindow) ?? windowScene.windows.first else {
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
      NotificationCenter.default.post(name: Self.notificationName, object: maximumInsets, userInfo: ["finder": self])
    }
  }

}
