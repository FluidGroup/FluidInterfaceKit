import Foundation

public final class KeyboardObservation {

  private var keyValueObservation: NSKeyValueObservation
  private let onInvalidate: () -> Void

  init(keyValueObservation: NSKeyValueObservation, onInvalidate: @escaping () -> Void) {
    self.keyValueObservation = keyValueObservation
    self.onInvalidate = onInvalidate
  }

  deinit {
    keyValueObservation.invalidate()
  onInvalidate()
  }
}
