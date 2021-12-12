//
// Copyright (c) 2021 Copyright (c) 2021 Eureka, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit

final class ScrollController {

  private var scrollObserver: NSKeyValueObservation?
  private var shouldStop: Bool = false
  private var previousValue: CGPoint?
  private weak var trackingScrollView: UIScrollView?
  private var originalShowsVerticalScrollIndicator = true

  init() {

  }

  func lockScrolling() {
    shouldStop = true
  }

  func unlockScrolling() {
    shouldStop = false
  }

  func startTracking(scrollView: UIScrollView) {
    self.trackingScrollView = scrollView
    self.originalShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator

    scrollObserver?.invalidate()
    scrollObserver = scrollView.observe(\.contentOffset, options: .old) { [weak self, weak _scrollView = scrollView] scrollView, change in

      guard let scrollView = _scrollView else { return }
      guard let self = self else { return }
      self.handleScrollViewEvent(scrollView: scrollView, change: change)
    }
  }

  func endTracking() {
    scrollObserver?.invalidate()
    trackingScrollView?.showsVerticalScrollIndicator = originalShowsVerticalScrollIndicator
    scrollObserver = nil
  }

  private func handleScrollViewEvent(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {

    guard var proposedValue = change.oldValue else { return }

    guard shouldStop else {
      scrollView.showsVerticalScrollIndicator = true
      return
    }

    guard scrollView.contentOffset != proposedValue else { return }

    guard proposedValue != previousValue else { return }

    let representation = ScrollViewRepresentation(from: scrollView)

    if representation.isReachedToEdge(.top) {
      proposedValue = representation.contentOffsetFitToEdge(.top, contentOffset: proposedValue)
    }

    if representation.isReachedToEdge(.right) {
      proposedValue = representation.contentOffsetFitToEdge(.right, contentOffset: proposedValue)
    }

    if representation.isReachedToEdge(.left) {
      proposedValue = representation.contentOffsetFitToEdge(.left, contentOffset: proposedValue)
    }

    if representation.isReachedToEdge(.bottom) {
      proposedValue = representation.contentOffsetFitToEdge(.bottom, contentOffset: proposedValue)
    }

    previousValue = scrollView.contentOffset

    scrollView.setContentOffset(proposedValue, animated: false)
    scrollView.showsVerticalScrollIndicator = false
  }

}

struct ScrollViewRepresentation {

  enum Edge {
    case top
    case left
    case right
    case bottom
  }

  let contentInset: UIEdgeInsets
  let contentOffset: CGPoint
  let contentSize: CGSize
  let bounds: CGRect

  init(
    from scrollView: UIScrollView
  ) {

    self.contentOffset = scrollView.contentOffset
    if #available(iOS 11.0, *) {
      self.contentInset = scrollView.adjustedContentInset
    } else {
      self.contentInset = scrollView.contentInset
    }
    self.bounds = scrollView.bounds
    self.contentSize = scrollView.contentSize
  }

  func isReachedToEdge(_ edge: Edge) -> Bool {

    switch edge {
    case .top:
      return -contentInset.top >= contentOffset.y
    case .left:
      return -contentInset.left >= contentOffset.x
    case .right:
      return (contentSize.width - bounds.width + contentInset.right) <= contentOffset.x
    case .bottom:
      return (contentSize.height - bounds.height + contentInset.bottom) <= contentOffset.y
    }

  }

  func contentOffsetFitToEdge(_ edge: Edge, contentOffset: CGPoint) -> CGPoint {

    switch edge {
    case .top:
      return .init(x: contentOffset.x, y: -contentInset.top)
    case .left:
      return .init(x: -contentInset.left, y: contentOffset.y)
    case .right:
      return .init(x: (contentSize.width - bounds.width + contentInset.right), y: contentOffset.y)
    case .bottom:
      return .init(x: contentOffset.x, y: (contentSize.height - bounds.height + contentInset.bottom))
    }

  }

}
