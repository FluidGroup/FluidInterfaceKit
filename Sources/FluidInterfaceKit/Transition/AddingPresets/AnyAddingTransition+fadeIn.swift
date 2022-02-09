//
//  File.swift
//  
//
//  Created by Jinsei Shima on 2022/02/09.
//

import UIKit

extension AnyAddingTransition {

  public static func fadeIn(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      context.contentView.backgroundColor = .clear

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        context.toViewController.view.alpha = 1
      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}
