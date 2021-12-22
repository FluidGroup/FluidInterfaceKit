import Foundation

enum RunLoopActivityObserving {

  struct Subscription {
    let observer: CFRunLoopObserver?
  }

  static func addObserver(
    acitivity: CFRunLoopActivity,
    callback: @escaping (CFRunLoopActivity) -> Void
  ) -> Subscription {

    let o = CFRunLoopObserverCreateWithHandler(
      kCFAllocatorDefault,
      acitivity.rawValue,
      true,
      Int.max,
      { observer, activity in
        callback(activity)
      }
    )

    CFRunLoopAddObserver(CFRunLoopGetMain(), o, CFRunLoopMode.defaultMode)

    return .init(observer: o)
  }

  static func remove(_ subscription: Subscription) {
    subscription.observer.map {
      CFRunLoopRemoveObserver(CFRunLoopGetMain(), $0, CFRunLoopMode.defaultMode)
    }
  }

}
